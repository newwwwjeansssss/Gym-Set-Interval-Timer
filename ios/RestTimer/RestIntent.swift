import AppIntents

struct StartRestIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "开始休息"
    static let description = IntentDescription("按保存的时长开始组间休息；再次执行会重新计时。请先打开组间并允许通知。")
    static var supportedModes: IntentModes { [.background] }
    static var authenticationPolicy: IntentAuthenticationPolicy { .alwaysAllowed }

    @MainActor
    func perform() async throws -> some IntentResult {
        try await RestService.shared.start(requestPermission: false)
        return .result()
    }
}

struct RestShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: StartRestIntent(), phrases: ["用\(.applicationName)开始休息"],
                    shortTitle: "开始休息", systemImageName: "timer")
    }
}
