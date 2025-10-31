//
//  Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
//

import SwiftUI

struct RoundedTextField: View {
    @Binding var text: String
    var placeholder: String
    var suffix: String?
    var isSecured = false
    @FocusState var isFocused: Bool

    private enum Constants {
        static let horizontalPadding: CGFloat = 12
        static let verticalPadding: CGFloat = 10
        static let cornerRadius: CGFloat = 8
    }

    var body: some View {
        HStack {
            Group {
                if isSecured {
                    SecureField("", text: $text)
                        .focused($isFocused)
                        .font(FontSet.body)
                } else {
                    TextField("", text: $text)
                        .focused($isFocused)
                        .font(FontSet.body)
                }
            }
            .placeholder(when: text.isEmpty) {
                Text(placeholder)
                    .foregroundStyle(.gray50)
                    .font(FontSet.body)
            }
            .padding(.leading, Constants.horizontalPadding)
            .foregroundStyle(.gray10)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            if let suffix {
                Text(suffix)
                    .font(FontSet.body)
                    .foregroundStyle(.gray10)
                    .padding(.trailing, Constants.horizontalPadding)
            }
        }
        .padding(.vertical, Constants.verticalPadding)
        .background(Color.gray90)
        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            if shouldShow {
                placeholder()
            }
            self
        }
    }
}

#Preview {
    RoundedTextField(text: .constant(""), placeholder: "Placeholder").padding()
}
