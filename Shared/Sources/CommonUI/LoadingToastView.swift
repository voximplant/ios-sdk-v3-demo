//
//  Copyright (c) 2011-2026, Voximplant, Inc. All rights reserved.
//

import SwiftUI

public struct LoadingToastView: View {
    private let text: String
    @Binding private var isPresented: Bool

    private enum Constants {
        static let progressViewSize: CGFloat = 20
        static let padding: CGFloat = 12
        static let cornerRadius: CGFloat = 16
    }

    public init(text: String, isPresented: Binding<Bool>) {
        self.text = text
        self._isPresented = isPresented
    }

    public var body: some View {
        HStack {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.gray100)
                .foregroundStyle(.white)
                .frame(width: Constants.progressViewSize, height: Constants.progressViewSize)

            Text(text)
                .font(FontSet.bodyBold)
                .foregroundColor(.gray100)
        }
        .padding(Constants.padding)
        .background(.black.opacity(0.4))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
        .opacity(isPresented ? 1 : 0)
        .scaleEffect(isPresented ? 1 : 0.5)
        .animation(.spring(duration: 0.2), value: isPresented)
    }
}

#Preview {
    LoadingToastView(text: "Reconnection...", isPresented: .constant(true))
}
