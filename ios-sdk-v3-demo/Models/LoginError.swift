//
//  Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
//

enum LoginError: Error, CustomStringConvertible {
    case emptyCredentials
    case wrongState
    case loginFailed
    case connectFailed

    var description: String {
        switch self {
        case .emptyCredentials:
            "Both username and password fields are required."
        case .wrongState:
            "The application is not in a valid state to perform a login."
        case .loginFailed:
            "Login attempt failed due to invalid credentials."
        case .connectFailed:
            "The connection to the server could not be established."
        }
    }
}
