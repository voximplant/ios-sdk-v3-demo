//
//  Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
//

import SwiftUI
import VoximplantCalls

final class CallViewModel: ObservableObject {
    @AppStorage("destination") var destination = ""
    @Published var isInCall = false
    @Published private(set) var callState: CallState = .noCall
    @Published private(set) var isMuted = false
    @Published private(set) var callDuration: TimeInterval = 0

    private var currentCall: VICall? {
        didSet {
            isInCall = currentCall != nil
        }
    }
    private let callManager: VICallManager
    private let callSettings = VICallSettings()
    private var durationTimer: Timer?

    init() {
        self.callManager = VICallManager.shared
        callManager.delegate = self
    }

    func makeCall() {
        guard let call = callManager.createCall(destination: destination, settings: callSettings) else { return }
        call.delegate = self
        self.currentCall = call
        self.currentCall?.start()
        callState = .callConnecting
    }

    func answerCall() {
        currentCall?.answer(with: callSettings)
    }

    func rejectCall() {
        currentCall?.reject(with: .decline)
        currentCall = nil
        callState = .noCall
        isMuted = false
    }

    func hangup() {
        currentCall?.hangup()
        stopDurationTimer()
        currentCall = nil
        callState = .noCall
        isMuted = false
    }

    func toggleMute() {
        if let currentCall {
            currentCall.muteAudio(!isMuted)
            isMuted.toggle()
        }
    }

    private func startDurationTimer() {
        durationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateCallDuration()
        }
    }

    private func stopDurationTimer() {
        durationTimer?.invalidate()
        durationTimer = nil
        callDuration = 0
    }

    private func updateCallDuration() {
        callDuration = currentCall?.duration ?? 0
    }
}

extension CallViewModel: VICallManagerDelegate {
    func callManager(_ callManager: VICallManager, didReceiveIncomingCall call: VICall, withVideo video: Bool, headers: [String: String]?) {
        guard self.currentCall == nil else {
            call.reject(with: .decline)
            return
        }
        DispatchQueue.main.async {
            self.callState = .incomingCall(call.userDisplayName ?? "Unknown user")
            self.currentCall = call
            call.delegate = self
        }
    }
}

extension CallViewModel: VICallDelegate {
    func call(_ call: VICall, didStartRingingWithHeaders headers: [String: String]?) {}
    func call(_ call: VICall, didConnectWithHeaders headers: [String: String]?) {
        DispatchQueue.main.async {
            self.callState = .callConnected(call.userDisplayName ?? "Unknown user")
            self.startDurationTimer()
        }
    }
    func callDidStopRinging(_ call: VICall) {}
    func call(_ call: VICall, didDisconnectWithReason reason: VICallDisconnectReason, headers: [String: String]?) {
        DispatchQueue.main.async {
            self.stopDurationTimer()
            self.currentCall = nil
            self.callState = .noCall
            self.isMuted = false
        }
    }
    func call(_ call: VICall, didFailWithError error: VICallConnectionError, headers: [String: String]?) {
        DispatchQueue.main.async {
            self.stopDurationTimer()
            self.currentCall = nil
            self.callState = .noCall
            self.isMuted = false
        }
    }
    func call(_ call: VICall, didReceiveMessage message: String, headers: [String: String]?) {}
    func call(_ call: VICall, didReceiveInfo body: String, type: String, headers: [String: String]?) {}
    func call(_ call: VICall, didAddRemoteVideoStream videoStream: VIRemoteVideoStream) {}
    func call(_ call: VICall, didRemoveRemoteVideoStream videoStream: VIRemoteVideoStream) {}
    func callDidStartReconnecting(_ call: VICall) {}
    func callDidReconnect(_ call: VICall) {}
}
