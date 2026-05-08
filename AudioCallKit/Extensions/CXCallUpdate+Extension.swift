//
//  Copyright (c) 2011-2026, Voximplant, Inc. All rights reserved.
//

import CallKit

extension CXCallUpdate {
    func applyVoximplantConfiguration() {
        self.supportsDTMF = true
        self.supportsHolding = false
        self.supportsGrouping = false
        self.supportsUngrouping = false
    }
}
