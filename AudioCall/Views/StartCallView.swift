//
//  Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
//

import SwiftUI

struct StartCallView: View {
    @EnvironmentObject private var callViewModel: CallViewModel
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
                    .foregroundStyle(.gray10)

                Spacer()

                Button {
                    loginViewModel.logout()
                } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: Constants.logoutButtonSize, height: Constants.logoutButtonSize)
                        .foregroundStyle(.gray10)
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
    }
}

#Preview {
    StartCallView()
        .environmentObject(CallViewModel())
        .environmentObject(LoginViewModel())
}
