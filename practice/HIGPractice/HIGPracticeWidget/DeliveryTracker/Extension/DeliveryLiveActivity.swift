//
//  DeliveryLiveActivity.swift
//  HIGPractice
//
//  Created by YuSeongChoi on 2/26/26.
//

import ActivityKit
import SwiftUI
import WidgetKit

// 이 파일은 Delivery Live Activity의 Lock Screen/Dynamic Island 진입 구성을 담당합니다.
struct DeliveryTrackerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DeliveryAttributes.self) { context in
            LockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
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
                DeliveryCompactLeadingView(status: context.state.status)
            } compactTrailing: {
                DeliveryCompactTrailingView(estimatedArrival: context.state.estimatedArrival)
            } minimal: {
                DeliveryMinimalView(status: context.state.status)
            }
            .keylineTint(context.state.status.color)
        }
    }
}
