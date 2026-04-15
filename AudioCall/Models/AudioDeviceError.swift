//
//  Copyright (c) 2011-2026, Voximplant, Inc. All rights reserved.
//

enum AudioDeviceError: Error, CustomStringConvertible {
    case unsupportedDeviceDetected
    case internalError

    var description: String {
        switch self {
        case .unsupportedDeviceDetected:
            "Unsupported audio device detected."
        case .internalError:
            "An unexpected audio error occurred."
        }
    }
}
