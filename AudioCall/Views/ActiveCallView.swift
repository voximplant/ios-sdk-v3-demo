//
//  Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
//

import SwiftUI

struct ActiveCallView: View {
    @EnvironmentObject private var callViewModel: CallViewModel
    @EnvironmentObject private var audioDevicesViewModel: AudioDevicesViewModel

    private enum Constants {
        static let padding: CGFloat = 32
        static let topPadding: CGFloat = 64
        static let spacing: CGFloat = 40
        static let secondaryTextColor: Color = .gray100.opacity(0.6)
        static let avatarSize: CGFloat = 100
    }

    var body: some View {
        ZStack {
            backgroundView

            VStack(spacing: Constants.spacing) {
                VStack {
                    AvatarPlaceholder(size: Constants.avatarSize)

                    switch callViewModel.callState {
                    case .incomingCall(let displayName):
                        VStack {
                            Text(displayName)
                                .font(FontSet.largeTitle)
                                .foregroundStyle(.gray100)
                            Text("is calling")
                                .font(FontSet.bodyLarge)
                                .foregroundStyle(Constants.secondaryTextColor)
                        }
                    case .callConnected(let displayName):
                        VStack {
                            Text(displayName)
                                .font(FontSet.largeTitle)
                                .foregroundStyle(.gray100)
                            Text(formatDuration(callViewModel.callDuration))
                                .font(FontSet.bodyLarge)
                                .foregroundStyle(Constants.secondaryTextColor)
                        }
                    case .callConnecting:
                        Text("Connecting...")
                            .font(FontSet.largeTitle)
                            .foregroundStyle(.gray100)
                    case .noCall:
                        EmptyView()
                    }

                    LoadingToastView(text: "Reconnecting...", isPresented: $callViewModel.isReconnecting)
                }
                Spacer()
                CallSettingsView()
                CallAcceptView()
            }
            .padding(.top, Constants.topPadding)
            .padding(.bottom, Constants.padding)
            .padding(.horizontal, Constants.padding)
        }
    }

    private var backgroundView: some View {
        ZStack {
            Color.black.opacity(0.7)
            Color.clear.background(.ultraThinMaterial)
        }
        .ignoresSafeArea()
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct CallAcceptView: View {
    @EnvironmentObject private var callViewModel: CallViewModel

    private enum Constants {
        static let buttonSize: CGFloat = 40
    }

    var body: some View {
        HStack(spacing: .zero) {
            switch callViewModel.callState {
            case .incomingCall:
                Button {
                    callViewModel.rejectCall()
                } label: {
                    Image(systemName: "phone.down.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: Constants.buttonSize, height: Constants.buttonSize)
                        .foregroundStyle(.gray100)
                        .padding()
                        .background(Color.red)
                        .clipShape(Circle())
                }

                Spacer()

                Button {
                    callViewModel.answerCall()
                } label: {
                    Image(systemName: "phone.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: Constants.buttonSize, height: Constants.buttonSize)
                        .foregroundStyle(.gray100)
                        .padding()
                        .background(Color.green)
                        .clipShape(Circle())
                }
            default:
                Button {
                    callViewModel.hangup()
                } label: {
                    Image(systemName: "phone.down.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: Constants.buttonSize, height: Constants.buttonSize)
                        .foregroundStyle(.white)
                        .padding()
                        .background(Color.red)
                        .clipShape(Circle())
                }
            }
        }
        .background(Color.clear)
    }
}

struct CallSettingsView: View {
    @EnvironmentObject private var callViewModel: CallViewModel
    @EnvironmentObject private var audioDevicesViewModel: AudioDevicesViewModel

    private enum Constants {
        static let buttonSize: CGFloat = 40
        static let buttonBackroundColor: Color = .black.opacity(0.4)
    }

    var body: some View {
        switch callViewModel.callState {
        case .incomingCall, .noCall:
            EmptyView()
        case .callConnected, .callConnecting:
            HStack(spacing: .zero) {
                Button {
                    callViewModel.toggleMute()
                } label: {
                    Image(systemName: callViewModel.isMuted ? "mic.slash.fill" : "mic.fill")
                        .resizable()
                        .transaction { $0.animation = nil }
                        .scaledToFit()
                        .frame(width: Constants.buttonSize, height: Constants.buttonSize)
                        .foregroundStyle(callViewModel.isMuted ? .black : .white)
                        .padding()
                        .background(callViewModel.isMuted ? .clear : Constants.buttonBackroundColor)
                        .background(callViewModel.isMuted ? AnyShapeStyle(Color.white) : AnyShapeStyle(.ultraThinMaterial))
                        .clipShape(Circle())
                }

                Spacer()

                Menu {
                    Picker("Select device", selection: $audioDevicesViewModel.selectedAudioDevice) {
                        ForEach(audioDevicesViewModel.audioDevices) { device in
                            Text(device.name)
                                .tag(device)
                        }
                    }
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: Constants.buttonSize, height: Constants.buttonSize)
                        .foregroundStyle(.white)
                        .padding()
                        .background(Constants.buttonBackroundColor)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .background(Color.clear)
        }
    }
}

#Preview {
    ZStack {
        let callVM = CallViewModel()
        StartCallView()
            .environmentObject(callVM)
            .environmentObject(LoginViewModel())
        ActiveCallView()
            .environmentObject(CallViewModel())
            .environmentObject(AudioDevicesViewModel())
    }
}
