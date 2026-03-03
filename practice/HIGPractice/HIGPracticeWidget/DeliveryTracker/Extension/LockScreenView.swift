//
//  LockScreenView.swift
//  HIGPractice
//
//  Created by YuSeongChoi on 3/3/26.
//

import SwiftUI
import WidgetKit

/*
 잠금 화면 Live Acitivty는 위젯보다 넓은 공간을 사용합니다.
 위젯과 비슷하지만 실시간 업데이트가 가능합니다.
 */

// MARK: - Lock Screen Live Activity View

struct LockScreenView: View {
    let context: ActivityViewContext<DeliveryAttributes>
    
    var body: some View {
        VStack(spacing: 12) {
            // 상단: 가게 정보 + 도착 시간
            HStack {
                // 가게 아이콘
                Image(systemName: "storefront.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(context.attributes.storeName)
                        .font(.headline)
                    Text(context.state.statusMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // 도착 예정 시간
                VStack(alignment: .trailing) {
                    Text(context.state.estimatedArrival, style: .date)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("도착 예정")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // 진행 바
            DeliveryProgressBar(progress: context.state.progress)
            
            // 하단: 단계 표시
            HStack {
                ForEach(DeliveryStatus.allCases, id: \.self) { status in
                    StepIndicator(
                        status: status,
                        isActive: context.state.status == status,
                        isCompleted: context.state.progress >= stepProgress(for: status)
                    )
                    
                    if status != .delivered {
                        Spacer()
                    }
                }
            }
        }
        .padding()
    }
    
    func stepProgress(for status: DeliveryStatus) -> Double {
        switch status {
        case .preparing: 0.2
        case .pickedUp:  0.5
        case .nearby:    0.8
        case .delivered: 1.0
        }
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

// MARK: - Delivery Progress Components

struct DeliveryProgressView: View {
    let currentStatus: DeliveryStatus
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(DeliveryStatus.allCases.enumerated()), id: \.element) { index, status in
                // 단계 원
                Circle()
                    .fill(isCompleted(status) ? status.color : Color.secondary.opacity(0.3))
                    .frame(width: 24, height: 24)
                    .overlay {
                        if isCompleted(status) {
                            Image(systemName: "checkmark")
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                        } else {
                            Text("\(index + 1)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                
                // 연결선 (마지막 제외)
                if status != .delivered {
                    Rectangle()
                        .fill(isCompleted(status) ? status.color : Color.secondary.opacity(0.3))
                        .frame(height: 2)
                }
            }
        }
    }
    
    func isCompleted(_ status: DeliveryStatus) -> Bool {
        let allCases = DeliveryStatus.allCases
        guard let currentIndex = allCases.firstIndex(of: currentStatus),
              let statusIndex = allCases.firstIndex(of: status) else {
            return false
        }
        return statusIndex <= currentIndex
    }
}

// MARK: - Arrival Time Display

struct ArrivalTimeView: View {
    let estimatedArrival: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // 카운트다운
            Text(estimatedArrival, style: .timer)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
            
            // 도착 예정 시각
            Text("\(estimatedArrival.formatted(date: .omitted, time: .shortened)) 도착 예정")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// 분 단위 카운트다운
struct MinutesCountdownView: View {
    let estimatedArrival: Date
    @State private var minutesRemaining: Int = 0
    
    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 2) {
            Text("\(minutesRemaining)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .contentTransition(.numericText())
            Text("분")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .onAppear { updateMinutes() }
        .onChange(of: estimatedArrival) { updateMinutes() }
    }
    
    private func updateMinutes() {
        minutesRemaining = max(0, Int(estimatedArrival.timeIntervalSinceNow / 60))
    }
}
