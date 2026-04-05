//
//  Copyright (c) 2011-2026, Voximplant, Inc. All rights reserved.
//

import Combine
import PushKit

protocol PushCallNotifierDelegate: AnyObject {
    func pushCallNotifier(
        _ notifier: PushCallNotifier,
        didReceiveIncomingPush push: VoximplantPush,
        with completion: @escaping () -> Void
    )
}

final class PushCallNotifier: NSObject {
    static let shared = PushCallNotifier()

    weak var delegate: PushCallNotifierDelegate?
    private var pushToken: Data?
    private let voIPRegistry: PKPushRegistry
    private let pushService: PushService

    override private init() {
        self.voIPRegistry = PKPushRegistry(queue: .main)
        self.pushService = PushService.shared
        super.init()
        self.voIPRegistry.delegate = self
        if let pushToken = voIPRegistry.pushToken(for: .voIP) {
            self.pushToken = pushToken
            self.pushService.register(voIPPushToken: pushToken, completion: nil)
        } else {
            self.voIPRegistry.desiredPushTypes = [.voIP]
        }
    }
}

extension PushCallNotifier: PKPushRegistryDelegate {
    func pushRegistry(
        _ registry: PKPushRegistry,
        didReceiveIncomingPushWith payload: PKPushPayload,
        for type: PKPushType,
        completion pushCompletion: @escaping () -> Void
    ) {
        guard let callUuid = pushService.handlePushNotification(pushPayload: payload.dictionaryPayload),
              let push = VoximplantPush(from: payload.dictionaryPayload, callUuid: callUuid) else {
            return
        }

        delegate?.pushCallNotifier(self, didReceiveIncomingPush: push, with: pushCompletion)
    }

    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        pushToken = pushCredentials.token
        pushService.register(voIPPushToken: pushCredentials.token, completion: nil)
    }

    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        if let pushToken {
            PushService.shared.unregister(voIPPushToken: pushToken, completion: nil)
        }
        pushToken = nil
    }
}
