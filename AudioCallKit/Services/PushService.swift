//
//  Copyright (c) 2011-2026, Voximplant, Inc. All rights reserved.
//

import Foundation
import VoximplantCore

final class PushService {
    static let shared = PushService()

    private let client: VIClient
    private let bundleId: String

    private init() {
        let bundleId = Bundle.main.bundleIdentifier
        if let bundleId {
            self.bundleId = bundleId
        } else {
            self.bundleId = "Unknown"
        }
        self.client = VIClient.shared
    }

    func register(voIPPushToken token: Data, completion: ((Result<Void, Error>) -> Void)?) {
        client.registerVoIPPushNotificationsToken(token, group: bundleId) { error in
            if let error {
                completion?(.failure(error))
            } else {
                completion?(.success(()))
            }
        }
    }

    func unregister(voIPPushToken token: Data, completion: ((Result<Void, Error>) -> Void)?) {
        client.unregisterVoIPPushNotificationsToken(token, group: bundleId) { error in
            if let error {
                completion?(.failure(error))
            } else {
                completion?(.success(()))
            }
        }
    }

    func handlePushNotification(pushPayload: [AnyHashable: Any]) -> UUID? {
        client.handlePushNotification(pushPayload: pushPayload)
    }
}
