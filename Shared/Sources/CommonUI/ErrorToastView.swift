//
//  Copyright (c) 2011-2026, Voximplant, Inc. All rights reserved.
//

import SwiftUI

public struct ErrorToastView: View {
    private let message: String

    private enum Constants {
        static let cornerRadius: CGFloat = 16
    }

    public init(message: String) {
        self.message = message
    }

    public var body: some View {
        Text(message)
            .font(FontSet.bodyBold)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red50)
            .foregroundStyle(Color.gray100)
            .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
            .shadow(radius: 8)
    }
}

#Preview {
    ErrorToastView(message: "Something went wrong!")
}
