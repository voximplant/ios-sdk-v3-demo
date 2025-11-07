//
//  Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
//

import SwiftUI
import VoximplantCore

struct SelectedNodeView: View {
    @Binding var isPresentedNodePicker: Bool
    @Binding var selectedNode: VINode

    @State private var isPressed = false

    private enum Constants {
        static let horizontalPadding: CGFloat = 12
        static let verticalPadding: CGFloat = 6
        static let cornerRadius: CGFloat = 8
    }

    var body: some View {
        HStack {
            Text("Node \(selectedNode.rawValue + 1)")
                .font(FontSet.body)
                .padding(.leading, Constants.horizontalPadding)
                .foregroundStyle(.gray10)

            Spacer()

            Image(.arrowDown)
                .rotationEffect(.degrees(isPresentedNodePicker ? 180 : 0))
                .animation(.spring(), value: isPresentedNodePicker)
                .padding(.trailing, Constants.horizontalPadding)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Constants.verticalPadding)
        .background(Color.gray90)
        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
        .opacity(isPressed ? 0.7 : 1.0)
        .onTapGesture {
            isPresentedNodePicker.toggle()
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: .zero)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

#Preview {
    SelectedNodeView(isPresentedNodePicker: .constant(false), selectedNode: .constant(VINode.node4))
        .padding()
}
