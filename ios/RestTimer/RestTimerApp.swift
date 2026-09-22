import SwiftUI
import UserNotifications

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
        willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .list]
    }
}

@main
struct RestTimerApp: App {
    private let delegate = NotificationDelegate()
    init() {
        UNUserNotificationCenter.current().delegate = delegate
    }
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
