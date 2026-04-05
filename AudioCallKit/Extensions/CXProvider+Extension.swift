//
//  Copyright (c) 2011-2026, Voximplant, Inc. All rights reserved.
//

import CallKit

extension CXProvider {
    func reportIncomingCall(
        with uuid: UUID,
        from userName: String,
        displayName: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: userName)
        update.hasVideo = false
        update.localizedCallerName = displayName
        update.applyVoximplantConfiguration()

        reportNewIncomingCall(with: uuid, update: update) { error in
            // CallKit can reject new incoming call in the following cases
            // https://developer.apple.com/documentation/callkit/cxerrorcodeincomingcallerror-swift.struct/code
            if let error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
