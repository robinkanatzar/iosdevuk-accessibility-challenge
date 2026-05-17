//
//  FavouriteToggleFeedback.swift
//  IOSDevuk26
//

import AVFoundation
import UIKit

@MainActor
enum FavouriteToggleFeedback {
    private enum Sound: String {
        case bell
        case pop
    }

    private static var configuredAudioSession = false
    private static var players: [Sound: AVAudioPlayer] = [:]

    static func added(hapticsEnabled: Bool = true, soundsEnabled: Bool = true) {
        if hapticsEnabled {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        if soundsEnabled {
            play(.bell)
        }
    }

    static func removed(hapticsEnabled: Bool = true, soundsEnabled: Bool = true) {
        if hapticsEnabled {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        if soundsEnabled {
            play(.pop)
        }
    }

    private static func play(_ sound: Sound) {
        configureAudioSessionIfNeeded()

        if let player = players[sound] {
            player.currentTime = 0
            player.play()
            return
        }

        guard let url = soundURL(for: sound),
              let player = try? AVAudioPlayer(contentsOf: url) else { return }

        players[sound] = player
        player.prepareToPlay()
        player.play()
    }

    private static func configureAudioSessionIfNeeded() {
        guard !configuredAudioSession else { return }

        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        configuredAudioSession = true
    }

    private static func soundURL(for sound: Sound) -> URL? {
        Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3", subdirectory: "Sounds")
            ?? Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3")
    }
}
