//
//  Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
//

import SwiftUI

struct StartCallView: View {
    @EnvironmentObject private var callViewModel: CallViewModel
    @EnvironmentObject private var loginViewModel: LoginViewModel
    @FocusState private var destinationFieldIsFocused: Bool

    private enum Constants {
        static let trailingPadding: CGFloat = 8
        static let spacing: CGFloat = 20
    }

    var body: some View {
        ZStack {
            VStack(spacing: Constants.spacing) {
                Spacer()

                Text("Logged in as \(loginViewModel.displayName)")
                    .font(.largeTitle)
                    .foregroundStyle(Color.black)

                RoundedTextField(text: $callViewModel.destination, placeholder: "Call to")
                    .focused($destinationFieldIsFocused)

                FullWidthButton(title: "Call") {
                    destinationFieldIsFocused = false
                    callViewModel.makeCall()
                }

                Spacer()
            }
            .padding()
        }
        .fullScreenCover(isPresented: $callViewModel.isInCall) {
            ZStack {
                BackgroundClearView()
                ActiveCallView()
            }
        }
        .safeAreaInset(edge: .top, alignment: .trailing) {
            Button {
                loginViewModel.logout()
            } label: {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .foregroundStyle(Color.black)
                    .padding()
            }
            .padding(.trailing, Constants.trailingPadding)
        }
    }
}

#Preview {
    StartCallView()
        .environmentObject(CallViewModel())
        .environmentObject(LoginViewModel())
}
