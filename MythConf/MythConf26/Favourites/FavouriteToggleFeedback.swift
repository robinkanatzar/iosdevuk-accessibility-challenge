//
//  FavouriteToggleFeedback.swift
//  IOSDevuk26
//

import UIKit

enum FavouriteToggleFeedback {
    static func added() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func removed() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
