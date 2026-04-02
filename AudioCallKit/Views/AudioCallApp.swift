//
//  Copyright (c) 2011-2026, Voximplant, Inc. All rights reserved.
//

import SwiftUI

@main
struct AudioCallApp: App {
    @StateObject private var callViewModel: CallViewModel
    @StateObject private var loginViewModel: LoginViewModel
    @StateObject private var audioDevicesViewModel: AudioDevicesViewModel

    init() {
        let callViewModel = CallViewModel()
        PushCallNotifier.shared.delegate = callViewModel
        _callViewModel = StateObject(wrappedValue: callViewModel)
        _loginViewModel = StateObject(wrappedValue: LoginViewModel())
        _audioDevicesViewModel = StateObject(wrappedValue: AudioDevicesViewModel())
    }

    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(loginViewModel)
                .fullScreenCover(isPresented: $loginViewModel.isLoggedIn) {
                    StartCallView()
                        .environmentObject(callViewModel)
                        .environmentObject(loginViewModel)
                        .environmentObject(audioDevicesViewModel)
                }
        }
    }
}
