//
//  Copyright (c) 2011-2026, Voximplant, Inc. All rights reserved.
//

enum CallError: Error, CustomStringConvertible, Equatable {
    case startCallFailed(String? = nil)
    case answerFailed
    case answeredElsewhere
    case connectionLost
    case reportIncomingCallFailed

    var description: String {
        switch self {
        case .startCallFailed(let message):
            "Failed to start the call." + (message.map { " \($0)" } ?? "")
        case .answerFailed:
            "Failed to answer the call."
        case .answeredElsewhere:
            "The call was answered on another device."
        case .connectionLost:
            "The call was lost due to a network issue."
        case .reportIncomingCallFailed:
            "Failed to report the incoming call."
        }
    }
}
