//
//  Copyright (c) 2011-2026, Voximplant, Inc. All rights reserved.
//

import Foundation

struct VoximplantPush {
    var callUuid: UUID
    let remoteDisplayName: String
    let remoteNumber: String

    init?(from pushPayload: [AnyHashable: Any], callUuid: UUID) {
        guard let voximplantContent = pushPayload["voximplant"] as? [String: Any],
              let displayName = voximplantContent["display_name"] as? String,
              let sipUri = voximplantContent["sipuri"] as? String else {
            return nil
        }

        self.remoteDisplayName = displayName
        self.remoteNumber = String(sipUri.dropFirst(4))
        self.callUuid = callUuid
    }
}
