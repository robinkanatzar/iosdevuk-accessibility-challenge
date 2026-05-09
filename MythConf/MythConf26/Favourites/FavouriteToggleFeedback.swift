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

    static func added() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        play(.bell)
    }

    static func removed() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        play(.pop)
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
