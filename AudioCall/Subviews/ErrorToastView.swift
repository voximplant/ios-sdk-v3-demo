//
//  Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
//

import SwiftUI

struct ErrorToastView: View {
    let message: String

    private enum Constants {
        static let cornerRadius: CGFloat = 16
    }

    var body: some View {
        Text(message)
            .font(FontSet.bodyBold)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.red50)
            .foregroundStyle(.gray100)
            .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
            .shadow(radius: 8)
    }
}

#Preview {
    ErrorToastView(message: "Something went wrong!")
}
