//
//  Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
//

enum CallState: Equatable {
    case incomingCall(String)
    case callConnected(String)
    case callConnecting
    case noCall

    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.incomingCall(_), .incomingCall(_)),
            (.callConnected(_), .callConnected(_)),
            (.callConnecting, .callConnecting),
            (.noCall, .noCall):
            return true
        default:
            return false
        }
    }
}
