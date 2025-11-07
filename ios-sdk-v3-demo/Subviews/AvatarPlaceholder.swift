//
//  Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
//

import SwiftUI

struct AvatarPlaceholder: View {
    let size: CGFloat

    private var viewSize: CGFloat { size }
    private var avatarSize: Font { .system(size: viewSize * 0.6) }

    private enum Constants {
        static let strokeColor: Color = .primary.opacity(0.06)
        static let placeholderForegroundColor: Color = .gray100.opacity(0.9)
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
                .frame(width: viewSize, height: viewSize)
            Image(systemName: "person.fill")
                .font(avatarSize)
                .foregroundStyle(Constants.placeholderForegroundColor)
                .frame(width: viewSize, height: viewSize)
                .background(Circle().fill(Color(.systemGray3)))
                .clipShape(Circle())
            Circle()
                .stroke(Constants.strokeColor, lineWidth: 1)
                .frame(width: viewSize, height: viewSize)
        }
        .frame(width: viewSize, height: viewSize)
    }
}

#Preview {
    AvatarPlaceholder(size: 250)
}
