//
//  Copyright (c) 2011-2026, Voximplant, Inc. All rights reserved.
//

import SwiftUI

struct ToastModifier<E: CustomStringConvertible & Equatable>: ViewModifier {
    @Binding var error: E?
    @State private var toastMessage: String?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let toastMessage {
                    ErrorToastView(message: toastMessage)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding()
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: toastMessage)
            .onChange(of: error) { newValue in
                guard let newValue else { return }
                withAnimation { toastMessage = String(describing: newValue) }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    error = nil
                    withAnimation { toastMessage = nil }
                }
            }
    }
}

public extension View {
    func toast<E: CustomStringConvertible & Equatable>(error: Binding<E?>) -> some View {
        modifier(ToastModifier(error: error))
    }
}
