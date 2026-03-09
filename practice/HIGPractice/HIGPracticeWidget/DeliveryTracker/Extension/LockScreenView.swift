//
//  LockScreenView.swift
//  HIGPractice
//
//  Created by YuSeongChoi on 3/3/26.
//

import SwiftUI
import WidgetKit

// 이 파일은 잠금 화면/배너에서 표시되는 Delivery Live Activity 본문 UI를 정의합니다.
struct LockScreenView: View {
    let context: ActivityViewContext<DeliveryAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                DeliveryStoreHeader(context: context)
                Spacer()
                ArrivalCountdownView(estimatedArrival: context.state.estimatedArrival)
            }

            AnimatedStatusRow(status: context.state.status, message: context.state.statusMessage)

            DeliveryProgressBar(
                progress: context.state.progress,
                tint: context.state.status.color
            )

            HStack {
                ForEach(DeliveryStatus.allCases, id: \.self) { status in
                    StepIndicator(
                        status: status,
                        isActive: context.state.status == status,
                        isCompleted: isCurrentOrPassed(status)
                    )

                    if status != .delivered {
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .onAppear {
            WidgetActivityLogger.logAllActivities()
        }
    }

    private func isCurrentOrPassed(_ status: DeliveryStatus) -> Bool {
        let all = DeliveryStatus.allCases
        guard
            let currentIndex = all.firstIndex(of: context.state.status),
            let statusIndex = all.firstIndex(of: status)
        else { return false }
        return currentIndex >= statusIndex
    }
}

private struct DeliveryStoreHeader: View {
    let context: ActivityViewContext<DeliveryAttributes>

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(context.state.status.color.opacity(0.14))
                Image(systemName: "storefront.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(context.state.status.color)
            }
            .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(context.attributes.storeName)
                    .font(.headline)
                    .lineLimit(1)
                Text("주문 #\(context.attributes.orderNumber)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct ArrivalCountdownView: View {
    let estimatedArrival: Date

    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(estimatedArrival, style: .timer)
                .font(.title3.weight(.bold))
                .monospacedDigit()
                .contentTransition(.numericText(countsDown: true))
            Text(estimatedArrival, style: .time)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

private struct AnimatedStatusRow: View {
    let status: DeliveryStatus
    let message: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: status.symbolName)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(status.color)
                .contentTransition(.symbolEffect(.replace))
                .symbolEffect(.bounce, value: status)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .contentTransition(.interpolate)
        }
        .animation(.smooth(duration: 0.25), value: status)
    }
}

struct StepIndicator: View {
    let status: DeliveryStatus
    let isActive: Bool
    let isCompleted: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: status.symbolName)
                .font(.caption)
                .foregroundStyle(isCompleted ? status.color : .secondary)
                .symbolEffect(.bounce, value: isActive)
            
            Text(status.displayName)
                .font(.caption2)
                .foregroundStyle(isActive ? .primary : .secondary)
        }
    }
}
