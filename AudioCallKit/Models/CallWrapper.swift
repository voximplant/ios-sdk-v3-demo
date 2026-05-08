//
//  Copyright (c) 2011-2026, Voximplant, Inc. All rights reserved.
//

import VoximplantCalls

final class CallWrapper {
    var uuid: UUID {
        call?.callKitUUID ?? uuidOnInit
    }
    var hasStarted: Bool {
        guard let call else { return false }
        return call.state.isOneOf(.connected, .connecting, .reconnecting)
    }
    weak var delegate: VICallDelegate? {
        willSet {
            call?.delegate = nil
        }
        didSet {
            call?.delegate = delegate
        }
    }
    var call: VICall? {
        willSet {
            call?.delegate = nil
        }
        didSet {
            call?.delegate = delegate
        }
    }

    private var uuidOnInit: UUID
    private var pushProcessingCompletion: (() -> Void)?

    init(uuid: UUID, call: VICall?, withPushCompletion pushProcessingCompletion: (() -> Void)? = nil) {
        self.uuidOnInit = uuid
        self.call = call
        self.pushProcessingCompletion = pushProcessingCompletion
    }

    func completePushProcessing() {
        self.pushProcessingCompletion?()
        self.pushProcessingCompletion = nil
    }
}
