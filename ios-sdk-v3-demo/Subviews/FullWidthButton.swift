//
//  Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
//

import SwiftUI

struct FullWidthButton: View {
    var title: String
    var backgroundColor: Color = .brand
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}
