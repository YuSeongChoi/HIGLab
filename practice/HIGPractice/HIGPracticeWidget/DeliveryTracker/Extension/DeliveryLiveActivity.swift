//
//  DeliveryLiveActivity.swift
//  HIGPractice
//
//  Created by YuSeongChoi on 2/26/26.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct DeliveryTrackerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DeliveryAttributes.self) { context in
            // Lock Screen / Banner UI
            DeliveryLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.state.status.displayName, systemImage: context.state.status.symbolName)
                        .font(.caption2)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.estimatedArrival, style: .time)
                        .font(.caption2)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(context.attributes.storeName)
                            .font(.subheadline)
                            .lineLimit(1)
                        ProgressView(value: context.state.progress)
                    }
                }
            } compactLeading: {
                Image(systemName: context.state.status.symbolName)
            } compactTrailing: {
                Text(context.state.estimatedArrival, style: .timer)
                    .font(.caption2)
            } minimal: {
                Image(systemName: context.state.status.symbolName)
            }
        }
    }
}

private struct DeliveryLockScreenView: View {
    let context: ActivityViewContext<DeliveryAttributes>

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: context.state.status.symbolName)
                .font(.title3)
                .foregroundStyle(context.state.status.color)

            VStack(alignment: .leading, spacing: 4) {
                Text(context.attributes.storeName)
                    .font(.headline)
                    .lineLimit(1)

                Text(context.state.statusMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                ProgressView(value: context.state.progress)
            }

            Spacer()

            Text(context.state.estimatedArrival, style: .time)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 6)
    }
}
