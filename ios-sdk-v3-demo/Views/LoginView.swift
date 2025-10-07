//
//  Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    @State private var showToast = false
    @State private var toastMessage = ""
    @EnvironmentObject private var loginViewModel: LoginViewModel

    private enum Constants {
        static let viewsSpacing: CGFloat = 20
        static let logoHeight: CGFloat = 50
    }

    var body: some View {
        ZStack {
            VStack(spacing: Constants.viewsSpacing) {
                Text("Audio call demo")
                    .font(.largeTitle)
                    .foregroundStyle(Color.black)
                RoundedTextField(text: $loginViewModel.username, placeholder: "user@app.account", suffix: loginViewModel.usernameSuffix)
                RoundedTextField(text: $loginViewModel.password, placeholder: "Password", isSecured: true)
                Picker("Node", selection: $loginViewModel.selectedNode) {
                    ForEach(loginViewModel.availableNodes, id: \.self) { node in
                        Text("Node \(node.rawValue + 1)")
                            .tag(node)
                    }
                }
                .pickerStyle(.menu)
                FullWidthButton(title: "Login") {
                    loginViewModel.login()
                }
            }
            .padding()

            VStack {
                Spacer()
                Image(.logo)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.brand)
                    .frame(height: Constants.logoHeight)
                    .padding()
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)

            VStack {
                if showToast {
                    ErrorToastView(message: toastMessage)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding()
                }
                Spacer()
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showToast)
        .onChange(of: loginViewModel.loginError) { newError in
            guard let error = newError else { return }
            toastMessage = String(describing: error)
            withAnimation {
                showToast = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                loginViewModel.loginError = nil
                withAnimation {
                    showToast = false
                }
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(LoginViewModel())
}
