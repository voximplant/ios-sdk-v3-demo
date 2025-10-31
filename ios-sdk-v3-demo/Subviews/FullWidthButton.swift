//
//  Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
//

import SwiftUI

struct FullWidthButton: View {
    var title: String
    var backgroundColor: Color = .purple40
    var action: () -> Void

    private enum Constants {
        static let minHeight: CGFloat = 44
        static let cornerRadius: CGFloat = 16
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(FontSet.bodyLargeBold)
                .frame(minHeight: Constants.minHeight)
                .foregroundStyle(.gray100)
                .frame(maxWidth: .infinity)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
        }
    }
}

#Preview {
    FullWidthButton(title: "Login") {}
}
