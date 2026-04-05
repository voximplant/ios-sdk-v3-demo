//
//  Copyright (c) 2011-2026, Voximplant, Inc. All rights reserved.
//

import Combine
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
    private var cancellables = Set<AnyCancellable>()

    init() {
        self.availableNodes = VINode.allCases
        self.isLoggedIn = false
        self.displayName = ""
        self.loginService = LoginService.shared
        self.observeLoginState()
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

    private func observeLoginState() {
        loginService.$isLoggedIn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoggedIn in
                guard let self else { return }
                self.isLoggedIn = isLoggedIn
                self.displayName = self.loginService.displayName
            }
            .store(in: &cancellables)
    }
}
