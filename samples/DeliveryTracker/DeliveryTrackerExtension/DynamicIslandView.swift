//
//  DynamicIslandView.swift
//  DeliveryTrackerExtension
//
//  Dynamic Island의 각 영역별 뷰 컴포넌트
//  재사용성과 가독성을 위해 별도 파일로 분리했습니다.
//
//  Dynamic Island 구조:
//  ┌─────────────────────────────────────┐
//  │  Leading    [Camera]    Trailing    │  ← Compact 모드
//  └─────────────────────────────────────┘
//
//  ┌─────────────────────────────────────┐
//  │  Leading    [Camera]    Trailing    │
//  │            Center                   │  ← Expanded 모드
//  │            Bottom                   │
//  └─────────────────────────────────────┘
//

import SwiftUI
import WidgetKit

// MARK: - Dynamic Island 뷰 빌더

/// Dynamic Island 뷰를 구성하는 빌더
/// DeliveryLiveActivity에서 사용됩니다.
struct DynamicIslandViews {
    
    // MARK: - Compact Views
    
    /// Compact 모드 - Leading (왼쪽) 뷰
    /// TrueDepth 카메라 왼쪽에 표시됩니다.
    struct CompactLeading: View {
        let state: DeliveryState
        
        var body: some View {
            HStack(spacing: 4) {
                // 상태 아이콘
                Image(systemName: state.status.iconName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(iconColor)
                    .symbolEffect(.pulse, isActive: isPulsing)
            }
        }
        
        /// 아이콘 색상
        private var iconColor: Color {
            switch state.status {
            case .ordered:
                return .blue
            case .preparing, .ready:
                return .orange
            case .pickedUp, .delivered:
                return .green
            }
        }
        
        /// 펄스 애니메이션 활성화 여부
        private var isPulsing: Bool {
            state.status == .preparing || state.status == .pickedUp
        }
    }
    
    /// Compact 모드 - Trailing (오른쪽) 뷰
    /// TrueDepth 카메라 오른쪽에 표시됩니다.
    struct CompactTrailing: View {
        let state: DeliveryState
        
        var body: some View {
            // 남은 시간 표시
            Text(state.formattedRemainingTime)
                .font(.system(size: 12, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(.white)
                .contentTransition(.numericText(countsDown: true))
        }
    }
    
    // MARK: - Minimal View
    
    /// Minimal 모드 - 다른 Live Activity와 함께 표시될 때
    /// 한쪽 센서 옆에만 작은 공간이 할당됩니다.
    struct Minimal: View {
        let state: DeliveryState
        
        var body: some View {
            ZStack {
                // 원형 프로그레스 배경
                Circle()
                    .stroke(.white.opacity(0.2), lineWidth: 2)
                
                // 진행률 표시
                Circle()
                    .trim(from: 0, to: state.status.progress)
                    .stroke(
                        progressColor,
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: state.status.progress)
                
                // 중앙 아이콘
                Image(systemName: state.status.iconName)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white)
            }
            .padding(3)
        }
        
        private var progressColor: Color {
            state.status == .delivered ? .blue : .green
        }
    }
    
    // MARK: - Expanded Views
    
    /// Expanded 모드 - Leading 영역
    struct ExpandedLeading: View {
        let state: DeliveryState
        
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                // 상태 아이콘 (크게)
                Image(systemName: state.status.iconName)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(iconGradient)
                    .symbolEffect(.bounce, value: state.status)
            }
        }
        
        private var iconGradient: some ShapeStyle {
            switch state.status {
            case .ordered:
                return AnyShapeStyle(.blue.gradient)
            case .preparing, .ready:
                return AnyShapeStyle(.orange.gradient)
            case .pickedUp, .delivered:
                return AnyShapeStyle(.green.gradient)
            }
        }
    }
    
    /// Expanded 모드 - Trailing 영역
    struct ExpandedTrailing: View {
        let state: DeliveryState
        
        var body: some View {
            VStack(alignment: .trailing, spacing: 2) {
                // 남은 시간 (크게)
                Text(state.formattedRemainingTime)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .monospacedDigit()
                    .contentTransition(.numericText(countsDown: true))
                
                // 라벨
                Text("남음")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }
    
    /// Expanded 모드 - Center 영역 (TrueDepth 카메라 바로 아래)
    struct ExpandedCenter: View {
        let attributes: DeliveryAttributes
        let state: DeliveryState
        
        var body: some View {
            VStack(spacing: 2) {
                // 음식점 이름
                Text(attributes.restaurantName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                // 현재 상태
                Text(state.status.description)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }
    
    /// Expanded 모드 - Bottom 영역
    struct ExpandedBottom: View {
        let state: DeliveryState
        
        var body: some View {
            VStack(spacing: 10) {
                // 진행률 바
                progressBar
                
                // 단계 인디케이터
                stepsIndicator
                
                // 배달원 정보 (있을 경우)
                if let driverName = state.driverName {
                    driverInfo(name: driverName)
                }
            }
        }
        
        /// 진행률 바
        private var progressBar: some View {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 배경 트랙
                    Capsule()
                        .fill(.white.opacity(0.15))
                    
                    // 진행된 부분
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.green.opacity(0.8), .green],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * state.status.progress)
                        .animation(.spring(response: 0.4), value: state.status.progress)
                }
            }
            .frame(height: 4)
        }
        
        /// 단계 인디케이터
        private var stepsIndicator: some View {
            HStack(spacing: 0) {
                ForEach(Array(DeliveryStatus.allCases.enumerated()), id: \.element) { index, status in
                    // 단계 점
                    Circle()
                        .fill(stepColor(for: status))
                        .frame(width: 6, height: 6)
                        .overlay {
                            if status == state.status {
                                Circle()
                                    .stroke(.white, lineWidth: 1)
                                    .frame(width: 10, height: 10)
                            }
                        }
                    
                    // 마지막이 아니면 스페이서 추가
                    if index < DeliveryStatus.allCases.count - 1 {
                        Spacer()
                    }
                }
            }
        }
        
        /// 배달원 정보
        private func driverInfo(name: String) -> some View {
            HStack(spacing: 6) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.blue)
                
                Text("\(name) 배달원")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.8))
                
                Spacer()
                
                // 전화 버튼 (실제로는 딥링크로 처리)
                Image(systemName: "phone.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.green)
                    .padding(6)
                    .background(.green.opacity(0.2), in: Circle())
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
        }
        
        /// 단계별 색상
        private func stepColor(for status: DeliveryStatus) -> Color {
            let currentIndex = DeliveryStatus.allCases.firstIndex(of: state.status) ?? 0
            let statusIndex = DeliveryStatus.allCases.firstIndex(of: status) ?? 0
            
            if statusIndex < currentIndex {
                return .green  // 완료된 단계
            } else if statusIndex == currentIndex {
                return .green  // 현재 단계
            } else {
                return .white.opacity(0.3)  // 미완료 단계
            }
        }
    }
}

// MARK: - 애니메이션 컨테이너

/// 상태 변경 시 애니메이션을 적용하는 컨테이너
struct AnimatedStatusContainer<Content: View>: View {
    let state: DeliveryState
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        content()
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: state.status)
    }
}

// MARK: - Preview Helpers

#if DEBUG
/// Dynamic Island 프리뷰를 위한 더미 뷰
struct DynamicIslandPreviewContainer: View {
    let state: DeliveryState
    
    var body: some View {
        VStack(spacing: 20) {
            // Compact 시뮬레이션
            HStack(spacing: 40) {
                DynamicIslandViews.CompactLeading(state: state)
                DynamicIslandViews.CompactTrailing(state: state)
            }
            .padding()
            .background(.black, in: Capsule())
            
            // Minimal 시뮬레이션
            DynamicIslandViews.Minimal(state: state)
                .frame(width: 30, height: 30)
                .background(.black, in: Circle())
            
            // Expanded 시뮬레이션
            VStack(spacing: 8) {
                HStack {
                    DynamicIslandViews.ExpandedLeading(state: state)
                    Spacer()
                    DynamicIslandViews.ExpandedTrailing(state: state)
                }
                
                DynamicIslandViews.ExpandedCenter(
                    attributes: .preview,
                    state: state
                )
                
                DynamicIslandViews.ExpandedBottom(state: state)
            }
            .padding()
            .background(.black, in: RoundedRectangle(cornerRadius: 40))
        }
        .padding()
    }
}

#Preview("Compact & Minimal") {
    VStack(spacing: 30) {
        DynamicIslandPreviewContainer(state: .previewOrdered)
        DynamicIslandPreviewContainer(state: .previewPickedUp)
    }
}

#Preview("Expanded - 주문") {
    DynamicIslandPreviewContainer(state: .previewOrdered)
}

#Preview("Expanded - 배달중") {
    DynamicIslandPreviewContainer(state: .previewPickedUp)
}
#endif
