//
//  Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
//

import SwiftUI

struct ErrorToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.body)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.red)
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .shadow(radius: 8)
    }
}

#Preview {
    ErrorToastView(message: "Something went wrong!")
}
