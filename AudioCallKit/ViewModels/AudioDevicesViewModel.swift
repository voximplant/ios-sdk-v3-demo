//
//  Copyright (c) 2011-2026, Voximplant, Inc. All rights reserved.
//

import AVFAudio
import SwiftUI
import VoximplantCore

final class AudioDevicesViewModel: ObservableObject {
    @Published var error: AudioDeviceError?
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
        updateAudioDevices()
    }

    private func selectAudioDevice(_ audioDevice: AudioDevice) {
        guard let chosenDevice = audioDeviceService.deviceList.first(where: { $0.id == audioDevice.id }) else {
            self.error = .internalError
            return
        }
        audioDeviceService.setActiveDevice(chosenDevice) { [weak self] error in
            guard let error else { return }
            self?.showErrorIfNeeded(error)
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

    private func showErrorIfNeeded(_ error: VIAudioDeviceError) {
        DispatchQueue.main.async {
            switch error.type {
            case .deviceAlreadyActive, .noSuchDeviceInDeviceList:
                break
            case .unsupportedDevice:
                self.error = .unsupportedDeviceDetected
            case .internalError:
                self.error = .internalError
            default:
                self.error = .internalError
            }
        }
    }
}

extension AudioDevicesViewModel: VIAudioManagerDelegate {
    func audioManager(_ audioManager: VIAudioManager, didReceiveError error: VIAudioDeviceError) {
        showErrorIfNeeded(error)
    }

    func audioManager(_ audioManager: VIAudioManager, didAddDevice device: VIAudioDevice) {
        DispatchQueue.main.async {
            self.updateAudioDevices()
        }
    }

    func audioManager(_ audioManager: VIAudioManager, didRemoveDevice device: VIAudioDevice) {
        DispatchQueue.main.async {
            self.updateAudioDevices()
        }
    }
}
