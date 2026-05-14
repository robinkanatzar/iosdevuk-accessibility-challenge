//
//  NotificationManager.swift
//  MythConf26
//

import Foundation
import UserNotifications

@MainActor
class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    func scheduleNotifications(for sessions: [[Session]], allTalks: [Talk], viewModel: ViewModel, simulatedNow: Date) {
        // 1. Clear existing reminders to avoid duplicates/ghosts
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // 2. Schedule each favourite individually
        for day in sessions {
            for session in day {
                for talkID in session.contentIDs {
                    if viewModel.favouriteIds.contains(talkID), let talk = allTalks.first(where: { $0.id == talkID }) {
                        let content = UNMutableNotificationContent()
                        content.title = "Session Starting Soon"
                        let speakers = viewModel.speakersFrom(talkID: talk.id)
                        let location = viewModel.locationNameFrom(locationID: talk.locationID)
                        content.body = "'\(talk.talkTitle)' by \(speakers) is starting in 10 minutes in \(location)."
                        content.sound = .default
                        
                        let triggerDate = session.startTime.addingTimeInterval(-600)
                        let delay = triggerDate.timeIntervalSince(simulatedNow)
                        let finalInterval = delay > 0 ? delay : 5
                        
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: finalInterval, repeats: false)
                        let request = UNNotificationRequest(
                            identifier: talk.id.uuidString,
                            content: content,
                            trigger: trigger
                        )
                        
                        UNUserNotificationCenter.current().add(request)
                        print("Scheduled individual notification for \(talk.talkTitle) (Delay: \(Int(finalInterval))s)")
                    }
                }
            }
        }
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("!!! FOREGROUND NOTIFICATION PRESENTING: \(notification.request.content.body)")
        completionHandler([.banner, .list, .sound])
    }
}
