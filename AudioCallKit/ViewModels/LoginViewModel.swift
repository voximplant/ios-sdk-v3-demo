//
//  Copyright (c) 2011-2026, Voximplant, Inc. All rights reserved.
//

import SwiftUI
import VoximplantCore

final class LoginViewModel: ObservableObject {
    @Published var isLoggedIn: Bool
    @Published var loginError: LoginError?
    @Published var displayName: String

    var usernameSuffix: String {
        loginService.usernameSuffix
    }
    let availableNodes: [VINode]

    private let loginService: LoginService

    init() {
        self.availableNodes = VINode.allCases
        self.isLoggedIn = false
        self.displayName = ""
        self.loginService = LoginService.shared
        self.loginService.onLoginStateChanged = { [weak self] loggedIn in
            guard let self else { return }
            self.isLoggedIn = loggedIn
            self.displayName = self.loginService.displayName
        }
    }

    func login() {
        loginService.login { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let name):
                self.displayName = name
                self.loginError = nil
            case .failure(let error):
                self.loginError = error
            }
        }
    }

    func logout() {
        loginService.disconnect()
    }
}
