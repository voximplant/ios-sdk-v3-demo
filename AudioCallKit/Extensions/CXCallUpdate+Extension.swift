//
//  Copyright (c) 2011-2026, Voximplant, Inc. All rights reserved.
//

import CallKit

extension CXCallUpdate {
    func applyVoximplantConfiguration() {
        self.supportsDTMF = true
        // For iOS 16 and lower(!)
        // this setting beeing set to true leads to call kit option "add call" beeing active
        // so unless we drop call kit holding support, this button will be active
        // see https://stackoverflow.com/a/40510928/27624280 for details
        self.supportsHolding = true
        self.supportsGrouping = false
        self.supportsUngrouping = false
    }
}
