import ActivityKit
import Foundation
import UserNotifications

@MainActor
final class RestService {
    static let shared = RestService()
    static let notificationID = "rest-finished"
    private let defaults: UserDefaults
    private let center = UNUserNotificationCenter.current()
    private var busy = false
    private let liveActivities: Bool

    init(defaults: UserDefaults = .standard, liveActivities: Bool = true) {
        self.defaults = defaults
        self.liveActivities = liveActivities
    }

    var duration: Int {
        let stored = defaults.integer(forKey: "duration")
        return stored == 0 ? 90 : min(3600, max(5, stored))
    }

    func start(requestPermission: Bool) async throws {
        guard !busy else { throw RestError.busy }
        busy = true
        defer { busy = false }
        var settings = await center.notificationSettings()
        if settings.authorizationStatus == .notDetermined && requestPermission {
            _ = try await center.requestAuthorization(options: [.alert, .sound])
            settings = await center.notificationSettings()
        }
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
            throw RestError.permission
        }
        let seconds = duration
        let content = UNMutableNotificationContent()
        content.title = "休息结束"
        content.body = "准备好了，开始下一组。"
        if !defaults.bool(forKey: "silent") { content.sound = .default }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(seconds), repeats: false)
        // A stable identifier replaces the previous pending reminder atomically on success.
        try await center.add(UNNotificationRequest(identifier: Self.notificationID, content: content, trigger: trigger))
        center.removeDeliveredNotifications(withIdentifiers: [Self.notificationID])
        defaults.set(seconds, forKey: "activeDuration")
        let start = Date()
        let end = start.addingTimeInterval(Double(seconds))
        defaults.set(end.timeIntervalSince1970, forKey: "endDate")
        if liveActivities { await showActivity(start: start, end: end) }
    }

    func cancel() async throws {
        guard !busy else { throw RestError.busy }
        busy = true
        defer { busy = false }
        center.removePendingNotificationRequests(withIdentifiers: [Self.notificationID])
        center.removeDeliveredNotifications(withIdentifiers: [Self.notificationID])
        defaults.removeObject(forKey: "endDate")
        if liveActivities { await endActivities() }
    }

    private func showActivity(start: Date, end: Date) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            defaults.set("请在系统设置中允许组间的实时活动。", forKey: "activityMessage")
            return
        }
        let content = ActivityContent(state: RestAttributes.ContentState(start: start, end: end), staleDate: end)
        let current = Activity<RestAttributes>.activities.filter { $0.activityState == .active || $0.activityState == .stale }
        if let activity = current.first {
            await activity.update(content)
            for duplicate in current.dropFirst() { await duplicate.end(nil, dismissalPolicy: .immediate) }
            defaults.removeObject(forKey: "activityMessage")
        } else {
            do {
                _ = try Activity.request(attributes: RestAttributes(), content: content, pushType: nil)
                defaults.removeObject(forKey: "activityMessage")
            } catch {
                // Notification remains scheduled even if iOS declines the Live Activity.
                defaults.set("计时已开始，灵动岛暂不可用。请打开 App 后重试。", forKey: "activityMessage")
            }
        }
    }

    private func endActivities() async {
        for activity in Activity<RestAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        defaults.removeObject(forKey: "activityMessage")
    }

    func reconcileActivities() async {
        guard liveActivities, !busy else { return }
        for activity in Activity<RestAttributes>.activities where activity.content.state.end <= Date() {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }

}

enum RestError: LocalizedError {
    case permission, busy
    var errorDescription: String? {
        switch self {
        case .permission: "请先打开「组间」，允许通知后再开始计时。若已拒绝，请在系统设置中开启通知。"
        case .busy: "正在设置计时，请稍后再试。"
        }
    }
}
