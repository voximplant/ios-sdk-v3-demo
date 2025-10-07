//
//  Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
//

import SwiftUI
import VoximplantCore

final class LoginViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var loginError: LoginError?
    @Published var displayName = ""
    @AppStorage("username") var username = ""
    @AppStorage("password") var password = ""
    @Published var selectedNode: VINode = .node4

    let usernameSuffix = ".voximplant.com"
    let availableNodes = VINode.allCases

    private let client: VIClient
    private let defaultDisplayName = "Unknown"

    init() {
        self.client = VIClient.shared
        client.delegate = self
    }

    func login() {
        guard !username.isEmpty, !password.isEmpty else {
            loginError = .emptyCredentials
            return
        }
        switch client.state {
        case .disconnected:
            client.connect(to: selectedNode) { [weak self] error in
                guard let self else { return }

                guard error == nil else {
                    DispatchQueue.main.async {
                        self.loginError = .connectFailed
                    }
                    return
                }
                self.loginWithPassword()
            }
        case .connected:
            loginWithPassword()
        case .loggedIn:
            isLoggedIn = true
        default:
            loginError = .wrongState
        }
    }

    func logout() {
        client.disconnect()
    }

    private func loginWithPassword() {
        let preparedUsername = username + usernameSuffix
        self.client.login(withPassword: self.password, user: preparedUsername) { [weak self] loginResult, error in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isLoggedIn = error == nil
                self.displayName = loginResult?.displayName ?? self.defaultDisplayName
                self.loginError = error == nil ? nil : .loginFailed
            }
        }
    }
}

extension LoginViewModel: VIClientSessionDelegate {
    func client(_ client: VIClient, didDisconnectWithReason reason: VIDisconnectReason) {
        DispatchQueue.main.async {
            self.isLoggedIn = false
        }
    }
}
