import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Live Activity Configuration

struct DeliveryLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DeliveryAttributes.self) { context in
            // 잠금 화면 레이아웃
            LockScreenView(context: context)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded 레이아웃
                DynamicIslandExpandedRegion(.leading) {
                    ExpandedLeadingView(context: context)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    ExpandedTrailingView(context: context)
                }
                DynamicIslandExpandedRegion(.center) {
                    ExpandedCenterView(context: context)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedBottomView(context: context)
                }
            } compactLeading: {
                // Compact Leading
                Image(systemName: context.state.status.symbolName)
                    .foregroundStyle(context.state.status.color)
            } compactTrailing: {
                // Compact Trailing
                Text(context.state.estimatedArrival, style: .timer)
                    .font(.caption2)
                    .monospacedDigit()
            } minimal: {
                // Minimal (다른 Activity와 함께 표시 시)
                Image(systemName: context.state.status.symbolName)
                    .foregroundStyle(context.state.status.color)
            }
        }
    }
}
