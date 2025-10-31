//
//  Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
//

import SwiftUI
import VoximplantCore

struct LoginView: View {
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var isNodePickerPresented = false
    @State private var sheetHeight: CGFloat = .zero
    @State private var selectedNode: VINode = .node4

    @EnvironmentObject private var loginViewModel: LoginViewModel

    private enum Constants {
        static let viewsSpacing: CGFloat = 20
        static let logoHeight: CGFloat = 50
        static let pickerHeight: CGFloat = 170
        static let nodePickerPadding: CGFloat = 12
    }

    var body: some View {
        ZStack {
            VStack(spacing: Constants.viewsSpacing) {
                Text("Audio call demo")
                    .font(FontSet.largeTitle)
                    .foregroundStyle(Color.black)
                RoundedTextField(text: $loginViewModel.username, placeholder: "user@app.account", suffix: loginViewModel.usernameSuffix)
                RoundedTextField(text: $loginViewModel.password, placeholder: "Password", isSecured: true)
                SelectedNodeView(isPresentedNodePicker: $isNodePickerPresented, selectedNode: $loginViewModel.selectedNode)
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
                    .foregroundStyle(.purple40)
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
        .sheet(isPresented: $isNodePickerPresented) {
            VStack {
                HStack(alignment: .bottom) {
                    Button {
                        isNodePickerPresented = false
                    } label: {
                        Text("Cancel")
                            .font(FontSet.bodyLarge)
                    }
                    Spacer()
                    Text("Select node")
                        .foregroundStyle(Color.gray10)
                        .font(FontSet.bodyLargeBold)
                    Spacer()

                    Button {
                        loginViewModel.selectedNode = selectedNode
                        isNodePickerPresented = false
                    } label: {
                        Text("Select")
                            .font(FontSet.bodyLargeBold)
                    }
                }
                .padding(Constants.nodePickerPadding)
                .onDisappear {
                    selectedNode = loginViewModel.selectedNode
                }

                Picker("", selection: $selectedNode) {
                    ForEach(loginViewModel.availableNodes, id: \.self) { node in
                        Text("Node \(node.rawValue + 1)")
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: Constants.pickerHeight)
            }
            .overlay {
                GeometryReader { geometry in
                    Color.clear.preference(key: HeightPreferenceKey.self, value: geometry.size.height)
                }
            }
            .onPreferenceChange(HeightPreferenceKey.self) { newHeight in
                sheetHeight = newHeight
            }
            .presentationDetents([.height(sheetHeight)])
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(LoginViewModel())
}
