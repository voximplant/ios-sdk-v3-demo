//
//  Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
//

import AVFAudio
import SwiftUI
import VoximplantCore

final class AudioDevicesViewModel: ObservableObject {
    @Published var selectedAudioDevice: AudioDevice? {
        didSet {
            if oldValue != selectedAudioDevice, let selectedAudioDevice {
                selectAudioDevice(selectedAudioDevice)
            }
        }
    }
    @Published var audioDevices: [AudioDevice] = []

    private let audioDeviceService: VIAudioManager

    init() {
        audioDeviceService = VIAudioManager.shared
        audioDeviceService.delegate = self

        if AVAudioSession.sharedInstance().category != .playAndRecord {
            try? AVAudioSession.sharedInstance().setCategory(.soloAmbient, mode: .default, options: [])
        }
        updateAudioDevices()
    }

    private func selectAudioDevice(_ audioDevice: AudioDevice) {
        if let chosenDevice = audioDeviceService.deviceList.first(where: { $0.id == audioDevice.id }) {
            audioDeviceService.setActiveDevice(chosenDevice) { _ in }
        }
    }

    private func updateAudioDevices() {
        selectedAudioDevice = getCurrentAudioDevice()
        audioDevices = getOrderedAudioDevicesList()
    }

    private func getOrderedAudioDevicesList() -> [AudioDevice] {
        let unorderedModels = audioDeviceService.deviceList.map {
            AudioDevice(name: $0.name, id: $0.id, type: $0.type)
        }
        let priority: [VIAudioDevice.VIDeviceType] = [.speaker, .receiver, .bluetooth, .wired]
        return priority.compactMap { type in
            unorderedModels.first { $0.type == type }
        }
    }

    private func getCurrentAudioDevice() -> AudioDevice? {
        guard let current = audioDeviceService.currentDevice else { return nil }
        return AudioDevice(name: current.name, id: current.id, type: current.type)
    }
}

extension AudioDevicesViewModel: VIAudioManagerDelegate {
    func audioManager(_ audioManager: VIAudioManager, didReceiveError error: VIAudioDeviceError) {}
    func audioManager(_ audioManager: VIAudioManager, didAddDevice device: VIAudioDevice) {
        DispatchQueue.main.async { [weak self] in
            self?.updateAudioDevices()
        }
    }

    func audioManager(_ audioManager: VIAudioManager, didRemoveDevice device: VIAudioDevice) {
        DispatchQueue.main.async { [weak self] in
            self?.updateAudioDevices()
        }
    }
}
