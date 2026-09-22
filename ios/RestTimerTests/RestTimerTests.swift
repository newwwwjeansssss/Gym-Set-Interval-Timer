import XCTest
import ActivityKit
import UserNotifications
@testable import RestTimer

final class RestTimerTests: XCTestCase {
    @MainActor func testDurationDefaultsAndBounds() {
        let name = "RestTimerTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        let service = RestService(defaults: defaults, liveActivities: false)
        XCTAssertEqual(service.duration, 90)
        defaults.set(120, forKey: "duration")
        XCTAssertEqual(service.duration, 120)
        defaults.set(-10, forKey: "duration")
        XCTAssertEqual(service.duration, 5)
        defaults.set(9999, forKey: "duration")
        XCTAssertEqual(service.duration, 3600)
    }

    @MainActor func testCancelClearsDeadlineAndPendingNotification() async throws {
        let name = "RestTimerTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        defaults.set(Date().addingTimeInterval(90).timeIntervalSince1970, forKey: "endDate")
        try await RestService(defaults: defaults, liveActivities: false).cancel()
        XCTAssertEqual(defaults.double(forKey: "endDate"), 0)
        let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
        XCTAssertFalse(pending.contains { $0.identifier == RestService.notificationID })
    }

    @MainActor func testPermissionFailureDoesNotCreateDeadline() async throws {
        let status = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
        guard status == .notDetermined || status == .denied else { throw XCTSkip("Requires unapproved notification permission") }
        let name = "RestTimerTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        do {
            try await RestService(defaults: defaults, liveActivities: false).start(requestPermission: false)
            XCTFail("Must reject start without permission")
        } catch RestError.permission { }
        XCTAssertEqual(defaults.double(forKey: "endDate"), 0)
    }
    @MainActor func testRestartReplacesReminderAndCancelRemovesIt() async throws {
        let center = UNUserNotificationCenter.current()
        let allowed = try await center.requestAuthorization(options: [.alert, .sound, .provisional])
        XCTAssertTrue(allowed)
        let name = "RestTimerTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        let service = RestService(defaults: defaults, liveActivities: false)
        defaults.set(30, forKey: "duration")
        try await service.start(requestPermission: false)
        defaults.set(60, forKey: "duration")
        defaults.set(true, forKey: "silent")
        try await service.start(requestPermission: false)
        let requests = await center.pendingNotificationRequests().filter { $0.identifier == RestService.notificationID }
        XCTAssertEqual(requests.count, 1)
        let request = try XCTUnwrap(requests.first)
        XCTAssertEqual((request.trigger as? UNTimeIntervalNotificationTrigger)?.timeInterval, 60)
        XCTAssertNil(request.content.sound)
        XCTAssertEqual(defaults.integer(forKey: "activeDuration"), 60)
        XCTAssertEqual(defaults.double(forKey: "endDate"), Date().addingTimeInterval(60).timeIntervalSince1970, accuracy: 2)
        try await service.cancel()
        let after = await center.pendingNotificationRequests()
        XCTAssertFalse(after.contains { $0.identifier == RestService.notificationID })
        XCTAssertEqual(defaults.double(forKey: "endDate"), 0)
    }
    @MainActor func testLiveActivityStartRestartAndCancel() async throws {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            throw XCTSkip("Live Activities disabled on test device")
        }
        let center = UNUserNotificationCenter.current()
        _ = try await center.requestAuthorization(options: [.alert, .sound, .provisional])
        let name = "RestActivityTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        let service = RestService(defaults: defaults)
        try await service.cancel()
        defaults.set(30, forKey: "duration")
        try await service.start(requestPermission: false)
        let first = try XCTUnwrap(Activity<RestAttributes>.activities.first, defaults.string(forKey: "activityMessage") ?? "No activity created")
        XCTAssertEqual(first.content.state.end.timeIntervalSince(first.content.state.start), 30, accuracy: 0.1)
        defaults.set(60, forKey: "duration")
        try await service.start(requestPermission: false)
        let current = Activity<RestAttributes>.activities.filter { $0.activityState == .active }
        XCTAssertEqual(current.count, 1)
        XCTAssertEqual(current.first?.id, first.id)
        let updated = try XCTUnwrap(current.first)
        // ActivityKit publishes state changes asynchronously after update returns.
        for _ in 0..<50 {
            if updated.content.state.end.timeIntervalSince(updated.content.state.start) == 60 { break }
            try await Task.sleep(for: .milliseconds(100))
        }
        XCTAssertEqual(updated.content.state.end.timeIntervalSince(updated.content.state.start), 60, accuracy: 0.1)
        try await service.cancel()
        XCTAssertTrue(Activity<RestAttributes>.activities.filter { $0.activityState == .active || $0.activityState == .stale }.isEmpty)
    }
}
