//
//  Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
//

import SwiftUI

struct AvatarPlaceholder: View {
    private enum Constants {
        static let viewSize: CGFloat = 100
        static let fontSize: Font = .system(size: Self.viewSize * 0.45)
        static let strokeColor: Color = .primary.opacity(0.06)
        static let placeholderForegroundColor: Color = .white.opacity(0.9)
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(.systemGray5), Color(.systemGray4)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: Constants.viewSize, height: Constants.viewSize)
            Image(systemName: "person.fill")
                .font(Constants.fontSize)
                .foregroundStyle(Constants.placeholderForegroundColor)
                .frame(width: Constants.viewSize, height: Constants.viewSize)
                .background(Circle().fill(Color(.systemGray3)))
                .clipShape(Circle())
            Circle()
                .stroke(Constants.strokeColor, lineWidth: 1)
                .frame(width: Constants.viewSize, height: Constants.viewSize)
        }
        .frame(width: Constants.viewSize, height: Constants.viewSize)
    }
}

#Preview {
    AvatarPlaceholder()
}
