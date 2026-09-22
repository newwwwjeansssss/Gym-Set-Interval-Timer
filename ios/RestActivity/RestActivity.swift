import ActivityKit
import WidgetKit
import SwiftUI

@main
struct RestActivityBundle: WidgetBundle {
    var body: some Widget { RestActivity() }
}

struct RestActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RestAttributes.self) { context in
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Label(context.isStale ? "休息结束" : "组间休息", systemImage: "timer")
                        .font(.headline)
                    Spacer()
                    countdown(context).font(.system(size: 32, weight: .light, design: .rounded))
                        .frame(width: 110, alignment: .trailing)
                }
                progress(context)
            }
            .padding(20)
            .activityBackgroundTint(.black)
            .activitySystemActionForegroundColor(.white)
            .foregroundStyle(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label("组间", systemImage: "timer").font(.headline)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    countdown(context).font(.system(size: 28, weight: .light, design: .rounded))
                        .frame(width: 100)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        progress(context)
                        Text(context.isStale ? "休息结束，开始下一组" : "休息中")
                            .font(.caption).foregroundStyle(.secondary)
                    }.padding(.top, 8)
                }
            } compactLeading: {
                Image(systemName: "timer").foregroundStyle(.white)
            } compactTrailing: {
                countdown(context).font(.caption.monospacedDigit()).frame(width: 48)
            } minimal: {
                Image(systemName: context.isStale ? "checkmark" : "timer")
            }
            .keylineTint(.white)
        }
    }

    @ViewBuilder private func countdown(_ context: ActivityViewContext<RestAttributes>) -> some View {
        if context.isStale {
            Text("00:00").monospacedDigit()
        } else {
            Text(timerInterval: context.state.start...context.state.end, countsDown: true)
                .monospacedDigit()
        }
    }

    @ViewBuilder private func progress(_ context: ActivityViewContext<RestAttributes>) -> some View {
        if context.isStale {
            ProgressView(value: 0).tint(.white)
        } else {
            ProgressView(timerInterval: context.state.start...context.state.end, countsDown: true) {
                EmptyView()
            } currentValueLabel: {
                EmptyView()
            }.tint(.white)
        }
    }
}
