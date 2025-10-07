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
        static let cornerRadius: CGFloat = 16
        static let strokeColor: Color = .gray.opacity(0.5)
        static let placeholderColor: Color = .gray
        static let textColor: Color = .black
        static let suffixColor: Color = .black.opacity(0.8)
    }

    var body: some View {
        HStack {
            Group {
                if isSecured {
                    SecureField("", text: $text)
                        .focused($isFocused)
                } else {
                    TextField("", text: $text)
                        .focused($isFocused)
                }
            }
            .placeholder(when: text.isEmpty) {
                Text(placeholder)
                    .foregroundStyle(Constants.placeholderColor)
            }
            .padding(.leading, Constants.horizontalPadding)
            .foregroundStyle(Constants.textColor)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            if let suffix {
                Text(suffix)
                    .foregroundStyle(Constants.suffixColor)
                    .padding(.trailing, Constants.horizontalPadding)
            }
        }
        .padding(.vertical, Constants.verticalPadding)
        .background(
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .stroke(Constants.strokeColor, lineWidth: 1)
        )
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
    RoundedTextField(text: .constant(""), placeholder: "Placeholder")
}
