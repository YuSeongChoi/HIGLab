//
//  DeliveryLiveActivity.swift
//  DeliveryTrackerExtension
//
//  Live Activity Widget의 메인 진입점
//  잠금화면과 Dynamic Island 모두 이곳에서 구성됩니다.
//

import ActivityKit
import WidgetKit
import SwiftUI

/// 배달 추적 Live Activity Widget
/// @main 어트리뷰트는 Widget Extension의 진입점을 나타냅니다.
@main
struct DeliveryLiveActivity: Widget {
    
    var body: some WidgetConfiguration {
        // ActivityConfiguration은 Live Activity를 정의합니다
        ActivityConfiguration(for: DeliveryAttributes.self) { context in
            
            // MARK: - Lock Screen / Banner UI
            // 잠금화면과 알림 배너에 표시되는 뷰
            // StandBy 모드(iPhone 가로 모드 충전 시)에서도 이 뷰가 표시됩니다.
            
            LockScreenView(
                attributes: context.attributes,
                state: context.state
            )
            .activityBackgroundTint(.black.opacity(0.8))
            .activitySystemActionForegroundColor(.white)
            
        } dynamicIsland: { context in
            
            // MARK: - Dynamic Island Configuration
            // Dynamic Island는 세 가지 표시 모드가 있습니다:
            // 1. Compact: 기본 최소화 상태
            // 2. Minimal: 다른 Activity와 함께 표시될 때
            // 3. Expanded: 길게 눌러 확장했을 때
            
            DynamicIsland {
                // MARK: Expanded Region
                // 사용자가 Dynamic Island를 길게 눌렀을 때 표시
                
                // 상단 Leading 영역
                DynamicIslandExpandedRegion(.leading) {
                    ExpandedLeadingView(state: context.state)
                }
                
                // 상단 Trailing 영역
                DynamicIslandExpandedRegion(.trailing) {
                    ExpandedTrailingView(state: context.state)
                }
                
                // 중앙 영역 (TrueDepth 카메라 아래)
                DynamicIslandExpandedRegion(.center) {
                    ExpandedCenterView(
                        attributes: context.attributes,
                        state: context.state
                    )
                }
                
                // 하단 영역
                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedBottomView(state: context.state)
                }
                
            } compactLeading: {
                // MARK: Compact Leading
                // 최소화 상태에서 왼쪽 (센서 왼쪽)
                CompactLeadingView(state: context.state)
                
            } compactTrailing: {
                // MARK: Compact Trailing
                // 최소화 상태에서 오른쪽 (센서 오른쪽)
                CompactTrailingView(state: context.state)
                
            } minimal: {
                // MARK: Minimal View
                // 다른 Live Activity와 공유할 때 표시되는 최소 뷰
                // 센서 한쪽에만 표시됨
                MinimalView(state: context.state)
            }
            // Dynamic Island 위젯의 딥링크 URL
            .widgetURL(URL(string: "deliverytracker://order"))
            // 콘텐츠 여백 설정
            .contentMargins(.horizontal, 4, for: .minimal)
            .contentMargins(.all, 8, for: .compactLeading)
            .contentMargins(.all, 8, for: .compactTrailing)
        }
    }
}

// MARK: - Compact Views (Dynamic Island 최소화 상태)

/// Compact Leading - 상태 아이콘
private struct CompactLeadingView: View {
    let state: DeliveryState
    
    var body: some View {
        Image(systemName: state.status.iconName)
            .font(.body)
            .foregroundStyle(iconColor)
            .symbolEffect(.pulse, isActive: state.status == .pickedUp)
    }
    
    private var iconColor: Color {
        switch state.status {
        case .ordered, .preparing, .ready:
            return .orange
        case .pickedUp:
            return .green
        case .delivered:
            return .blue
        }
    }
}

/// Compact Trailing - 남은 시간
private struct CompactTrailingView: View {
    let state: DeliveryState
    
    var body: some View {
        Text(state.formattedRemainingTime)
            .font(.caption2.bold())
            .foregroundStyle(.white)
            .monospacedDigit()
            .contentTransition(.numericText())
    }
}

/// Minimal View - 최소 표시
private struct MinimalView: View {
    let state: DeliveryState
    
    var body: some View {
        ZStack {
            // 배경 원형 프로그레스
            Circle()
                .stroke(.white.opacity(0.2), lineWidth: 2)
            
            Circle()
                .trim(from: 0, to: state.status.progress)
                .stroke(.green, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            // 중앙 아이콘
            Image(systemName: state.status.iconName)
                .font(.system(size: 12))
                .foregroundStyle(.white)
        }
        .padding(2)
    }
}

// MARK: - Expanded Views (Dynamic Island 확장 상태)

/// 확장 상태 - Leading 영역
private struct ExpandedLeadingView: View {
    let state: DeliveryState
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: state.status.iconName)
                .font(.title2)
                .foregroundStyle(.white)
                .symbolEffect(.bounce, value: state.status)
        }
    }
}

/// 확장 상태 - Trailing 영역
private struct ExpandedTrailingView: View {
    let state: DeliveryState
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(state.formattedRemainingTime)
                .font(.headline.bold())
                .foregroundStyle(.white)
                .contentTransition(.numericText())
            
            Text("남음")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}

/// 확장 상태 - Center 영역
private struct ExpandedCenterView: View {
    let attributes: DeliveryAttributes
    let state: DeliveryState
    
    var body: some View {
        VStack(spacing: 2) {
            Text(attributes.restaurantName)
                .font(.caption.bold())
                .foregroundStyle(.white)
            
            Text(state.status.rawValue)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}

/// 확장 상태 - Bottom 영역
private struct ExpandedBottomView: View {
    let state: DeliveryState
    
    var body: some View {
        VStack(spacing: 8) {
            // 진행률 바
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // 배경
                    Capsule()
                        .fill(.white.opacity(0.2))
                        .frame(height: 4)
                    
                    // 진행률
                    Capsule()
                        .fill(.green.gradient)
                        .frame(
                            width: geo.size.width * state.status.progress,
                            height: 4
                        )
                        .animation(.easeInOut, value: state.status.progress)
                }
            }
            .frame(height: 4)
            
            // 상태 단계 표시
            HStack {
                ForEach(DeliveryStatus.allCases, id: \.self) { status in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(stepColor(for: status))
                            .frame(width: 8, height: 8)
                        
                        if status == state.status {
                            Text(status.rawValue)
                                .font(.system(size: 8))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                    
                    if status != .delivered {
                        Spacer()
                    }
                }
            }
            
            // 배달원 정보
            if let driverName = state.driverName {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.caption)
                    Text("\(driverName) 배달원이 배달 중")
                        .font(.caption)
                }
                .foregroundStyle(.white.opacity(0.8))
            }
        }
    }
    
    private func stepColor(for status: DeliveryStatus) -> Color {
        let currentIndex = DeliveryStatus.allCases.firstIndex(of: state.status) ?? 0
        let statusIndex = DeliveryStatus.allCases.firstIndex(of: status) ?? 0
        
        if statusIndex <= currentIndex {
            return .green
        } else {
            return .white.opacity(0.3)
        }
    }
}

// MARK: - Preview

#Preview("Dynamic Island Compact", as: .dynamicIsland(.compact), using: DeliveryAttributes.preview) {
    DeliveryLiveActivity()
} contentStates: {
    DeliveryState.previewOrdered
    DeliveryState.previewPreparing
    DeliveryState.previewPickedUp
}

#Preview("Dynamic Island Expanded", as: .dynamicIsland(.expanded), using: DeliveryAttributes.preview) {
    DeliveryLiveActivity()
} contentStates: {
    DeliveryState.previewOrdered
    DeliveryState.previewPickedUp
}

#Preview("Dynamic Island Minimal", as: .dynamicIsland(.minimal), using: DeliveryAttributes.preview) {
    DeliveryLiveActivity()
} contentStates: {
    DeliveryState.previewPickedUp
}

#Preview("Lock Screen", as: .content, using: DeliveryAttributes.preview) {
    DeliveryLiveActivity()
} contentStates: {
    DeliveryState.previewOrdered
    DeliveryState.previewPreparing
    DeliveryState.previewPickedUp
    DeliveryState.previewDelivered
}
