//
//  Copyright (c) 2011-2026, Voximplant, Inc. All rights reserved.
//

import CommonUI
import SwiftUI

struct StartCallView: View {
    @StateObject private var callViewModel = CallViewModel()
    @EnvironmentObject private var loginViewModel: LoginViewModel
    @FocusState private var destinationFieldIsFocused: Bool

    private enum Constants {
        static let spacing: CGFloat = 20
        static let logoutButtonSize: CGFloat = 30
        static let avatarSize: CGFloat = 40
    }

    var body: some View {
        VStack {
            HStack {
                AvatarPlaceholder(size: Constants.avatarSize)

                Text(loginViewModel.displayName)
                    .font(FontSet.subTitle)
                    .foregroundStyle(Color.gray10)

                Spacer()

                Button {
                    loginViewModel.logout()
                } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: Constants.logoutButtonSize, height: Constants.logoutButtonSize)
                        .foregroundStyle(Color.gray10)
                        .padding()
                }
            }
            .padding()

            VStack(spacing: Constants.spacing) {
                Spacer()

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
        .toast(error: $callViewModel.callError)
        .onChange(of: callViewModel.destination) { _ in
            callViewModel.destination = callViewModel.destination.filter { !$0.isWhitespace }
        }
    }
}

#Preview {
    StartCallView()
        .environmentObject(CallViewModel())
        .environmentObject(LoginViewModel())
}
