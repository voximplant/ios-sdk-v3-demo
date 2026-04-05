//
//  Copyright (c) 2011-2026, Voximplant, Inc. All rights reserved.
//

import SwiftUI
import VoximplantCore

final class LoginService {
    static let shared = LoginService()

    var onLoginStateChanged: ((Bool) -> Void)?
    private(set) var isLoggedIn = false
    private(set) var displayName = ""
    let usernameSuffix = ".voximplant.com"

    @AppStorage("username") private var username = ""
    @AppStorage("password") private var password = ""
    @AppStorage("selectedNode") private var selectedNode: VINode = .node4

    private let client = VIClient.shared
    private let defaultDisplayName = "Unknown"

    private init() {
        client.delegate = self
    }

    func login(completion: @escaping (Result<String, LoginError>) -> Void) {
        guard !username.isEmpty, !password.isEmpty else {
            completion(.failure(.emptyCredentials))
            return
        }
        switch client.state {
        case .disconnected:
            client.connect(to: selectedNode) { [weak self] error in
                guard let self else { return }

                guard error == nil else {
                    DispatchQueue.main.async {
                        completion(.failure(.connectFailed))
                    }
                    return
                }
                self.performLogin(completion: completion)
            }
        case .connected:
            performLogin(completion: completion)
        case .loggedIn:
            isLoggedIn = true
            completion(.success(displayName))
        default:
            completion(.failure(.wrongState))
        }
    }

    func disconnect() {
        client.disconnect()
    }

    private func performLogin(completion: @escaping (Result<String, LoginError>) -> Void) {
        let preparedUsername = username + usernameSuffix
        client.login(withPassword: self.password, user: preparedUsername) { [weak self] loginResult, error in
            guard let self else { return }
            DispatchQueue.main.async {
                if error == nil {
                    self.isLoggedIn = true
                    self.displayName = loginResult?.displayName ?? self.defaultDisplayName
                    self.onLoginStateChanged?(self.isLoggedIn)
                    completion(.success(self.displayName))
                } else {
                    self.isLoggedIn = false
                    self.onLoginStateChanged?(self.isLoggedIn)
                    completion(.failure(.loginFailed))
                }
            }
        }
    }
}

extension LoginService: VIClientSessionDelegate {
    func client(_ client: VIClient, didDisconnectWithReason reason: VIDisconnectReason) {
        DispatchQueue.main.async {
            self.isLoggedIn = false
            self.onLoginStateChanged?(self.isLoggedIn)
        }
    }
}
