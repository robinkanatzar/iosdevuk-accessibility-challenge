//
//  NotificationManager.swift
//  MythConf26
//

import Foundation
import UserNotifications
import SwiftUI

@MainActor
class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
            return granted
        } catch {
            print("Notification permission error: \(error.localizedDescription)")
            return false
        }
    }

    func scheduleNotifications(
        for sessions: [[Session]],
        allTalks: [Talk],
        viewModel: ViewModel,
        now: Date,
        reminderTiming: FavouriteReminderTiming
    ) async {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        guard let leadTime = reminderTiming.leadTime else {
            print("Favourite reminders are off")
            return
        }

        for day in sessions {
            for session in day {
                for talkID in session.contentIDs {
                    guard viewModel.favouriteIds.contains(talkID),
                          let talk = allTalks.first(where: { $0.id == talkID })
                    else { continue }

                    let content = UNMutableNotificationContent()
                    content.title = "Session Starting Soon"
                    let speakers = viewModel.speakersFrom(talkID: talk.id)
                    let location = viewModel.locationNameFrom(locationID: talk.locationID)
                    content.body = "'\(talk.talkTitle)' by \(speakers) is starting in \(reminderTiming.notificationBodyText) in \(location)."
                    content.sound = .default
                    content.userInfo = ["talkID": talk.id.uuidString, "url": "MythConf26://talk/\(talk.id.uuidString)"]

                    // Offset from simulated "now" → real current time
                    // e.g. simulated trigger is 25s away → real trigger is also 25s from now
                    let simulatedTriggerDate = session.startTime.addingTimeInterval(-leadTime)
                    let offsetFromNow = simulatedTriggerDate.timeIntervalSince(now)
                    guard offsetFromNow > 0 else {
                        print("Skipping '\(talk.talkTitle)' reminder because its trigger is in the past")
                        continue
                    }
                    let realTriggerDate = Date().addingTimeInterval(offsetFromNow)

                    let components = Calendar.current.dateComponents(
                        [.year, .month, .day, .hour, .minute, .second],
                        from: realTriggerDate
                    )
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                    print("Scheduled '\(talk.talkTitle)' at real time \(realTriggerDate) (offset: \(Int(offsetFromNow))s)")

                    let request = UNNotificationRequest(identifier: talk.id.uuidString, content: content, trigger: trigger)
                    do {
                        try await UNUserNotificationCenter.current().add(request)
                    } catch {
                        print("Notification schedule error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    func pendingReminderDebugSummary() async -> String {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        guard let first = requests.first else {
            return "No pending reminders"
        }

        let title = first.content.title
        let body = first.content.body
        return "\(requests.count) pending reminder. \(title). \(body)"
    }

    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("!!! FOREGROUND NOTIFICATION PRESENTING: \(notification.request.content.body)")
        completionHandler([.banner, .list, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        print("🔔 [DeepLink] didReceive fired")
        print("🔔 [DeepLink] userInfo: \(response.notification.request.content.userInfo)")

        guard
            let urlString = response.notification.request.content.userInfo["url"] as? String
        else {
            print("🔔 [DeepLink] ❌ No 'url' key in userInfo")
            return
        }
        print("🔔 [DeepLink] urlString: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("🔔 [DeepLink] ❌ Could not form URL from: \(urlString)")
            return
        }
        print("🔔 [DeepLink] Opening URL: \(url)")
        await UIApplication.shared.open(url)
        print("🔔 [DeepLink] UIApplication.open returned")
    }
}
