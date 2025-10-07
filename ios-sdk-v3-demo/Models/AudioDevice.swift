//
//  Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
//

import VoximplantCore

struct AudioDevice: Identifiable, Hashable {
    let name: String
    let id: String
    let type: VIAudioDevice.VIDeviceType
}
