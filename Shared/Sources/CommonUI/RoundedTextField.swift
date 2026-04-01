//
//  Copyright (c) 2011-2026, Voximplant, Inc. All rights reserved.
//

import SwiftUI

public struct RoundedTextField: View {
    @Binding private var text: String
    private var placeholder: String
    private var suffix: String?
    private var isSecured = false
    @FocusState private var isFocused: Bool

    private enum Constants {
        static let horizontalPadding: CGFloat = 12
        static let verticalPadding: CGFloat = 10
        static let cornerRadius: CGFloat = 8
    }

    public init(text: Binding<String>, placeholder: String, suffix: String? = nil, isSecured: Bool = false) {
        _text = text
        self.placeholder = placeholder
        self.suffix = suffix
        self.isSecured = isSecured
    }

    public var body: some View {
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
                    .foregroundStyle(Color.gray50)
                    .font(FontSet.body)
            }
            .padding(.leading, Constants.horizontalPadding)
            .foregroundStyle(Color.gray10)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            if let suffix {
                Text(suffix)
                    .font(FontSet.body)
                    .foregroundStyle(Color.gray10)
                    .padding(.trailing, Constants.horizontalPadding)
            }
        }
        .padding(.vertical, Constants.verticalPadding)
        .background(Color.gray90)
        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
    }
}

public extension View {
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
