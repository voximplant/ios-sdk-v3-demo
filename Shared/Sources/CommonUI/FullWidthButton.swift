//
//  Copyright (c) 2011-2026, Voximplant, Inc. All rights reserved.
//

import SwiftUI

public struct FullWidthButton: View {
    @Environment(\.isEnabled) private var isEnabled

    private var title: String
    private var backgroundColor: Color = .purple40
    private var action: () -> Void

    public init(title: String, backgroundColor: Color = .purple40, action: @escaping () -> Void) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.action = action
    }

    private enum Constants {
        static let minHeight: CGFloat = 44
        static let cornerRadius: CGFloat = 16
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(FontSet.bodyLargeBold)
                .frame(minHeight: Constants.minHeight)
                .foregroundStyle(Color.gray100)
                .frame(maxWidth: .infinity)
                .background(isEnabled ? backgroundColor : backgroundColor.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    FullWidthButton(title: "Login") {}
}
