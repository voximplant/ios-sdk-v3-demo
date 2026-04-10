//
//  Copyright (c) 2011-2026, Voximplant, Inc. All rights reserved.
//

import AVFAudio
import CallKit
import Combine
import SwiftUI
import VoximplantCalls
import VoximplantCore

final class CallViewModel: NSObject, ObservableObject {
    @AppStorage("destination") var destination = ""
    @Published var isInCall = false
    @Published var isReconnecting = false
    @Published var callError: CallError?
    @Published private(set) var data = CallData()

    private var currentCall: CallWrapper? {
        willSet {
            currentCall?.delegate = nil
        }
        didSet {
            currentCall?.delegate = self
        }
    }
    private let callManager = VICallManager.shared
    private let callSettings = VICallSettings(callKitSupport: true)
    private var durationTimer: Timer?
    private let queue = DispatchQueue(label: "callkitserv")
    private let loginService = LoginService.shared
    private let audioManager = VIAudioManager.shared
    private let callController = CXCallController()
    private var pendingEndCallActions: [UUID] = []
    private let provider: CXProvider = {
        let providerConfiguration = CXProviderConfiguration()
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.maximumCallGroups = 1
        providerConfiguration.supportedHandleTypes = [.generic]
        providerConfiguration.ringtoneSound = "noisecollector-beam.aiff"
        providerConfiguration.iconTemplateImageData = UIImage(resource: .callKitLogo).pngData()
        return CXProvider(configuration: providerConfiguration)
    }()
    private var clientIsLoggedIn = false
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        callManager.delegate = self
        provider.setDelegate(self, queue: queue)
        VICore.delegateQueue = self.queue
        self.observeLoginState()
    }

    func makeCall() {
        let handle = CXHandle(type: .generic, value: destination)
        let action = CXStartCallAction(call: UUID(), handle: handle)
        callController.requestTransaction(with: [action]) { [weak self] error in
            guard error != nil else { return }
            self?.showError(.startCallFailed())
        }
    }

    func answerCall() {
        guard let uuid = currentCall?.uuid else { return }
        let action = CXAnswerCallAction(call: uuid)
        callController.requestTransaction(with: [action]) { [weak self] error in
            guard error != nil else { return }
            self?.showError(.answerFailed)
            self?.callClear()
        }
    }

    func endCall() {
        guard let uuid = currentCall?.uuid else { return }
        let action = CXEndCallAction(call: uuid)
        callController.requestTransaction(with: [action]) { [weak self] error in
            guard error != nil else { return }
            self?.callClear()
        }
    }

    func toggleMute() {
        guard let uuid = currentCall?.uuid else { return }
        let newMuteValue = !data.isMuted
        let action = CXSetMutedCallAction(call: uuid, muted: newMuteValue)
        callController.requestTransaction(with: [action]) { _ in }
    }
}

// MARK: - VICallManagerDelegate
extension CallViewModel: VICallManagerDelegate {
    func callManager(
        _ callManager: VICallManager,
        didReceiveIncomingCall call: VICall,
        withVideo video: Bool,
        headers: [String: String]?
    ) {
        guard currentCall?.call == nil else {
            call.reject(with: .decline)
            return
        }
        guard let incomingCallUuid = call.callKitUUID, let user = call.user, let displayName = call.userDisplayName else {
            call.reject(with: .decline)
            return
        }
        guard pendingEndCallActions.removeFirst(where: { $0 == incomingCallUuid }) == nil else {
            call.reject(with: .decline)
            return
        }

        if let currentCall {
            if currentCall.uuid == incomingCallUuid {
                print("call from recent push")
                currentCall.call = call
                commitPendingTransactions()
                DispatchQueue.main.async {
                    self.data.state = .incomingCall(displayName)
                    self.isInCall = true
                }
            } else {
                print("another call has been reported, reject a new one")
                call.reject(with: .decline)
            }
        } else {
            print("no current call, created new one")
            currentCall = CallWrapper(
                uuid: incomingCallUuid,
                call: call,
                withPushCompletion: nil
            )
            provider.reportIncomingCall(with: incomingCallUuid, from: user, displayName: displayName) { [weak self] result in
                switch result {
                case .success:
                    self?.commitPendingTransactions()
                    DispatchQueue.main.async {
                        self?.data.state = .incomingCall(displayName)
                        self?.isInCall = true
                    }
                case .failure:
                    call.reject(with: .decline)
                    self?.showError(.reportIncomingCallFailed)
                    self?.callClear()
                }
            }
        }
    }
}

// MARK: - VICallDelegate
extension CallViewModel: VICallDelegate {
    func call(_ call: VICall, didConnectWithHeaders headers: [String: String]?) {
        guard let currentCall else {
            call.delegate = nil
            call.hangup()
            callClear()
            return
        }

        switch call.direction {
        case .incoming:
            currentCall.completePushProcessing()
        case .outgoing:
            provider.reportOutgoingCall(with: currentCall.uuid, connectedAt: Date())
            let callinfo = CXCallUpdate()
            callinfo.localizedCallerName = call.userDisplayName
            callinfo.applyVoximplantConfiguration()
            provider.reportCall(with: currentCall.uuid, updated: callinfo)
        default:
            break
        }
        DispatchQueue.main.async {
            self.data.state = .callConnected(call.userDisplayName ?? "Unknown user")
            self.startDurationTimer()
        }
    }

    func call(_ call: VICall, didDisconnectWithReason reason: VICallDisconnectReason, headers: [String: String]?) {
        guard let currentCall else { return }
        let endReason: CXCallEndedReason = reason == .answeredElsewhere ? .answeredElsewhere : .remoteEnded
        switch reason {
        case .answeredElsewhere:
            showError(.answeredElsewhere)
        case .connectionLost:
            showError(.connectionLost)
        default:
            break
        }
        reportCallEnded(currentCall.uuid, endReason)
    }

    func call(_ call: VICall, didFailWithError error: VICallConnectionError, headers: [String: String]?) {
        guard let currentCall else { return }
        reportCallEnded(currentCall.uuid, .failed)
        showError(.startCallFailed(error.description))
    }

    func callDidStartReconnecting(_ call: VICall) {
        DispatchQueue.main.async {
            guard self.currentCall?.call == call else { return }
            self.isReconnecting = true
        }
    }

    func callDidReconnect(_ call: VICall) {
        DispatchQueue.main.async {
            guard self.currentCall?.call == call else { return }
            self.isReconnecting = false
        }
    }

    func call(_ call: VICall, didStartRingingWithHeaders headers: [String: String]?) {}
    func callDidStopRinging(_ call: VICall) {}
}

// MARK: - PushCallNotifierDelegate
extension CallViewModel: PushCallNotifierDelegate {
    func pushCallNotifier(
        _ notifier: PushCallNotifier,
        didReceiveIncomingPush push: VoximplantPush,
        with completion: @escaping () -> Void
    ) {
        guard currentCall == nil else {
            if currentCall?.uuid == push.callUuid {
                print("already managing call \(push.callUuid)")
            } else {
                print("skipped new call \(push.callUuid)")
            }
            return
        }

        currentCall = CallWrapper(uuid: push.callUuid, call: nil, withPushCompletion: completion)

        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: push.remoteNumber)
        update.localizedCallerName = push.remoteDisplayName
        provider.reportNewIncomingCall(with: push.callUuid, update: update) { [weak self] error in
            guard error != nil else { return }
            self?.currentCall?.completePushProcessing()
            self?.callClear()
        }

        loginService.login { [weak self] result in
            guard let self, case .failure = result else { return }
            reportCallEnded(push.callUuid, .failed)
        }
    }
}

// MARK: - CXProviderDelegate
extension CallViewModel: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        currentCall?.call?.reject(with: .decline, headers: nil)
    }

    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        guard currentCall == nil else {
            action.fail()
            return
        }

        guard let call = callManager.createCall(destination: destination, settings: callSettings) else {
            action.fail()
            return
        }

        currentCall = CallWrapper(uuid: action.callUUID, call: call)
        call.start()
        DispatchQueue.main.async {
            self.isInCall = true
            self.data.state = .callConnecting
        }
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        guard let currentCall, let call = currentCall.call else {
            action.fail()
            return
        }

        guard !currentCall.hasStarted else {
            action.fail()
            return
        }

        call.answer(with: callSettings)
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        guard let currentCall, let call = currentCall.call else {
            action.fail()
            return
        }

        let decline = call.direction == .incoming && call.state == .created
        if decline {
            call.reject(with: .decline, headers: nil)
        } else {
            call.hangup(withHeaders: nil)
        }
        action.fulfill(withDateEnded: Date())
    }

    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        guard let call = currentCall?.call else {
            action.fail()
            return
        }
        call.muteAudio(action.isMuted)
        DispatchQueue.main.async {
            self.data.isMuted = action.isMuted
        }
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXPlayDTMFCallAction) {
        guard let call = currentCall?.call else {
            action.fail()
            return
        }
        call.sendDTMF(action.digits) { error in
            if error == nil {
                action.fulfill()
            } else {
                action.fail()
            }
        }
    }

    func provider(_ provider: CXProvider, execute transaction: CXTransaction) -> Bool {
        if transaction.actions.first is CXStartCallAction {
            print("execute start call transaction immediately")
            return false
        }

        if clientIsLoggedIn, currentCall?.call != nil {
            print("execute transaction immediately")
            return false
        }

        // We take the first action cause transaction does not contain more than one in current implementation
        guard let endCallAction = transaction.actions.first as? CXEndCallAction else {
            return true
        }

        let callUUID = endCallAction.callUUID
        print("should reject VICall with callUUID: \(callUUID) after receiving")
        pendingEndCallActions.append(callUUID)
        endCallAction.fulfill(withDateEnded: Date())
        callClear()
        return true
    }

    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        audioManager.callKitProviderDidActivateAudioSession()
    }

    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        audioManager.callKitProviderDidDeactivateAudioSession()
    }
}

// MARK: - Private helpers
extension CallViewModel {
    private func reportCallEnded(_ uuid: UUID, _ endReason: CXCallEndedReason) {
        guard currentCall?.uuid == uuid else { return }
        provider.pendingCallActions(of: CXAction.self, withCall: uuid).forEach { $0.fail() }
        provider.reportCall(with: uuid, endedAt: Date(), reason: endReason)
        currentCall?.completePushProcessing()
        callClear()
    }

    private func showError(_ callError: CallError) {
        DispatchQueue.main.async {
            self.callError = callError
        }
    }

    private func commitPendingTransactions() {
        for transaction in provider.pendingTransactions {
            for action in transaction.actions {
                switch action {
                case let startAction as CXStartCallAction:
                    provider(provider, perform: startAction)
                case let answerAction as CXAnswerCallAction:
                    provider(provider, perform: answerAction)
                case let endAction as CXEndCallAction:
                    provider(provider, perform: endAction)
                case let muteAction as CXSetMutedCallAction:
                    provider(provider, perform: muteAction)
                case let dtmfAction as CXPlayDTMFCallAction:
                    provider(provider, perform: dtmfAction)
                default:
                    break
                }
            }
        }
    }

    private func failPendingTransactions() {
        for transaction in provider.pendingTransactions {
            for action in transaction.actions {
                action.fail()
            }
        }
    }

    private func observeLoginState() {
        loginService.$isLoggedIn
            .receive(on: self.queue)
            .sink { [weak self] isLoggedIn in
                guard let self else { return }
                self.clientIsLoggedIn = isLoggedIn
                guard !isLoggedIn, currentCall != nil else { return }
                failPendingTransactions()
                callClear()
            }
            .store(in: &cancellables)
    }

    private func resetCallData() {
        DispatchQueue.main.async {
            self.stopDurationTimer()
            self.data.state = .noCall
            self.data.isMuted = false
        }
    }

    private func startDurationTimer() {
        durationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.data.duration = self?.currentCall?.call?.duration ?? 0
        }
    }

    private func stopDurationTimer() {
        durationTimer?.invalidate()
        durationTimer = nil
        data.duration = 0
    }

    private func callClear() {
        currentCall = nil
        DispatchQueue.main.async {
            self.isInCall = false
            self.isReconnecting = false
            self.resetCallData()
        }
    }
}
