//
//  Copyright (c) 2011-2026, Voximplant, Inc. All rights reserved.
//

import VoximplantCore

struct AudioDevice: Identifiable, Hashable {
    let name: String
    let id: String
    let type: VIAudioDevice.VIDeviceType
}
