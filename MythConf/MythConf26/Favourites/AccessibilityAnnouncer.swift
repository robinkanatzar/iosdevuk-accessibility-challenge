//
//  AccessibilityAnnouncer.swift
//  IOSDevuk26
//

import UIKit

/// Posts VoiceOver announcements reliably.
///
/// iOS routinely drops `UIAccessibility.post(notification: .announcement, ...)`
/// when VoiceOver is busy (e.g. still speaking a button's activation feedback).
/// This helper queues the announcement behind any in-flight speech and retries
/// if the system reports that an announcement was not successful.
final class AccessibilityAnnouncer {
    static let shared = AccessibilityAnnouncer()

    private var pendingMessage: String?
    private var attemptsRemaining: Int = 0

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(announcementDidFinish(_:)),
            name: UIAccessibility.announcementDidFinishNotification,
            object: nil
        )
    }

    /// Speak `message` via VoiceOver. Waits briefly so that VoiceOver's own
    /// activation feedback can finish first, then posts a queued announcement
    /// and retries up to twice if the system reports it as unsuccessful.
    func announce(_ message: String) {
        pendingMessage = message
        attemptsRemaining = 3
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.post()
        }
    }

    private func post() {
        guard let message = pendingMessage, attemptsRemaining > 0 else { return }
        attemptsRemaining -= 1
        let attributed = NSAttributedString(
            string: message,
            attributes: [.accessibilitySpeechQueueAnnouncement: true]
        )
        UIAccessibility.post(notification: .announcement, argument: attributed)
    }

    @objc private func announcementDidFinish(_ notification: Notification) {
        guard let info = notification.userInfo,
              let spokenString = info[UIAccessibility.announcementStringValueUserInfoKey] as? String,
              spokenString == pendingMessage else { return }

        let wasSuccessful = (info[UIAccessibility.announcementWasSuccessfulUserInfoKey] as? Bool) ?? true
        if wasSuccessful {
            pendingMessage = nil
            attemptsRemaining = 0
        } else if attemptsRemaining > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.post()
            }
        } else {
            pendingMessage = nil
        }
    }
}
