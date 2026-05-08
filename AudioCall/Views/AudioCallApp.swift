//
//  Copyright (c) 2011-2026, Voximplant, Inc. All rights reserved.
//

import SwiftUI

@main
struct AudioCallApp: App {
    @StateObject private var loginViewModel = LoginViewModel()

    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(loginViewModel)
                .fullScreenCover(isPresented: $loginViewModel.isLoggedIn) {
                    StartCallView()
                        .environmentObject(loginViewModel)
                }
        }
    }
}
