//
//  Copyright (c) 2011-2026, Voximplant, Inc. All rights reserved.
//

import SwiftUI

public struct HeightPreferenceKey: PreferenceKey {
    public static let defaultValue: CGFloat = .zero

    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
