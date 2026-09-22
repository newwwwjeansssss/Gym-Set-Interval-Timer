import SwiftUI
import UserNotifications

struct ContentView: View {
    @AppStorage("duration") private var duration = 90
    @AppStorage("endDate") private var endDate = 0.0
    @AppStorage("activityMessage") private var activityMessage = ""
    @AppStorage("silent") private var silent = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var busy = false
    @State private var error: String?
    @State private var showSettings = false
    @State private var showDuration = false
    @State private var authorized = false

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        HStack {
                            Text("组间").font(.title3.weight(.semibold))
                            Spacer()
                            Button { showSettings = true } label: {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.body).frame(width: 44, height: 44)
                            }.accessibilityLabel("设置")
                        }
                        Spacer(minLength: 48)
                        TimelineView(.periodic(from: .now, by: 1)) { context in
                            let remaining = max(0, Int(ceil(endDate - context.date.timeIntervalSince1970)))
                            let running = remaining > 0
                            VStack(spacing: 18) {
                                Text(running ? "休息中" : endDate > 0 ? "休息结束" : "准备休息")
                                    .font(.subheadline).foregroundStyle(.secondary)
                                Text(timeString(running ? remaining : endDate > 0 ? 0 : duration))
                                    .font(.system(size: 88, weight: .light, design: .rounded))
                                    .monospacedDigit().minimumScaleFactor(0.5).lineLimit(1)
                                    .contentTransition(.numericText())
                                    .accessibilityLabel(running ? "剩余时间" : "休息时长")
                                    .accessibilityValue("\(running ? remaining : endDate > 0 ? 0 : duration)秒")
                            }.frame(maxWidth: .infinity)
                            Spacer(minLength: 48)
                            VStack(spacing: 20) {
                                HStack(spacing: 0) {
                                    ForEach([30, 60, 90, 120], id: \.self) { seconds in
                                        Button {
                                            duration = seconds
                                            if !running { endDate = 0 }
                                        } label: {
                                            Text("\(seconds)秒")
                                                .font(.subheadline.weight(duration == seconds ? .semibold : .regular))
                                                .frame(maxWidth: .infinity).frame(minHeight: 44)
                                                .background(duration == seconds ? Color.primary.opacity(0.07) : Color.clear, in: Capsule())
                                        }.accessibilityAddTraits(duration == seconds ? .isSelected : [])
                                    }
                                }
                                Button { showDuration = true } label: {
                                    HStack(spacing: 5) {
                                        Text("自定义 · \(timeString(duration))").monospacedDigit()
                                        Image(systemName: "chevron.down").font(.caption2)
                                    }.font(.footnote).foregroundStyle(.secondary).frame(minHeight: 44)
                                }
                                Button {
                                    Task {
                                        busy = true
                                        defer { busy = false }
                                        do {
                                            try await RestService.shared.start(requestPermission: true)
                                            await refreshPermission()
                                        } catch { self.error = error.localizedDescription }
                                    }
                                } label: {
                                    Text(busy ? "正在设置…" : running ? "重新计时" : "开始休息")
                                        .font(.headline).frame(maxWidth: .infinity).frame(height: 58)
                                        .foregroundStyle(Color(uiColor: .systemBackground))
                                        .background(Color.primary, in: Capsule())
                                }.disabled(busy).accessibilityIdentifier("startRest")
                                Group {
                                    if running {
                                        Button("取消计时") {
                                            Task {
                                                do { try await RestService.shared.cancel() }
                                                catch { self.error = error.localizedDescription }
                                            }
                                        }.disabled(busy)
                                    } else if !authorized {
                                        Button("开启通知") { Task { await enableNotifications() } }
                                    } else {
                                        Text("也可按住左侧操作按钮")
                                    }
                                }.font(.footnote).foregroundStyle(.secondary).frame(minHeight: 44)
                            }
                        }
                    }
                    .padding(.horizontal, 28).padding(.top, 8).padding(.bottom, 16)
                    .frame(minHeight: geometry.size.height)
                }
            }
            .background(Color(uiColor: .systemBackground))
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showSettings) { settings }
            .sheet(isPresented: $showDuration) {
                NavigationStack {
                    Form {
                        Stepper(value: $duration, in: 5...3600, step: 5) {
                            Text(timeString(duration)).font(.title2).monospacedDigit()
                        }
                        Text("自动保存，下次计时生效。").font(.footnote).foregroundStyle(.secondary)
                    }
                    .navigationTitle("休息时长").navigationBarTitleDisplayMode(.inline)
                    .toolbar { ToolbarItem(placement: .confirmationAction) {
                        Button("完成") {
                            if endDate <= Date().timeIntervalSince1970 { endDate = 0 }
                            showDuration = false
                        }
                    } }
                }.presentationDetents([.medium])
            }
            .alert("暂时无法开始", isPresented: Binding(get: { error != nil }, set: { if !$0 { error = nil } })) {
                Button("知道了") { error = nil }
            } message: { Text(error ?? "") }
            .task { await refreshPermission(); await RestService.shared.reconcileActivities() }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { Task { await refreshPermission(); await RestService.shared.reconcileActivities() } }
            }
        }.tint(.primary)
    }

    private func refreshPermission() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorized = settings.authorizationStatus == .authorized && settings.alertSetting == .enabled
    }

    private func enableNotifications() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        if settings.authorizationStatus == .notDetermined {
            do { _ = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) }
            catch { self.error = error.localizedDescription }
            await refreshPermission()
        } else if let url = URL(string: UIApplication.openSettingsURLString) {
            await UIApplication.shared.open(url)
        }
    }

    private func timeString(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    private var settings: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("短提示音", isOn: Binding(get: { !silent }, set: { silent = !$0 }))
                    Button(authorized ? "通知设置" : "开启通知") { Task { await enableNotifications() } }
                }
                Section("灵动岛与锁屏") {
                    Text("开始计时后自动显示。长按灵动岛查看进度。")
                    if !activityMessage.isEmpty { Text(activityMessage).foregroundStyle(.secondary) }
                    Text("若未显示，请在系统设置 → 组间中开启实时活动。到时停在 00:00；再次打开 App 或取消计时后清除。")
                        .foregroundStyle(.secondary)
                }
                Section("绑定操作按钮") {
                    Text("设置 → 操作按钮 → 快捷指令 → 组间 → 开始休息")
                    Text("每组结束按住一次，再次按住重新计时。")
                        .foregroundStyle(.secondary)
                }
                Section("提醒方式") {
                    Text("设置 → 通知 → 组间 → 横幅风格 → 临时")
                    Text("锁屏时显示锁屏通知。专注模式中请允许组间通知。")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("设置").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("完成") { showSettings = false } } }
        }
    }
}
