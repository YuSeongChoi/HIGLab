//
//  LockScreenView.swift
//  DeliveryTrackerExtension
//
//  잠금화면 및 알림 배너에 표시되는 Live Activity 뷰
//  StandBy 모드(가로 충전)에서도 이 뷰가 사용됩니다.
//

import SwiftUI
import WidgetKit

/// 잠금화면 Live Activity 뷰
/// 최대 160pt 높이의 제한된 공간에서 핵심 정보를 표시합니다.
struct LockScreenView: View {
    
    // MARK: - Properties
    
    /// 주문 속성 (정적 데이터)
    let attributes: DeliveryAttributes
    
    /// 현재 상태 (동적 데이터)
    let state: DeliveryState
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 12) {
            // 상단 행 - 음식점 정보 & 예상 시간
            topRow
            
            // 진행 상태 바
            progressBar
            
            // 하단 행 - 현재 상태 & 배달원 정보
            bottomRow
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - View Components
    
    /// 상단 행 - 음식점 및 예상 시간
    private var topRow: some View {
        HStack(alignment: .top) {
            // 음식점 정보
            HStack(spacing: 10) {
                // 음식점 아이콘
                ZStack {
                    Circle()
                        .fill(.orange.gradient)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "storefront.fill")
                        .font(.body)
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(attributes.restaurantName)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                    
                    Text(attributes.orderSummary)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // 예상 도착 시간
            VStack(alignment: .trailing, spacing: 2) {
                Text(state.formattedRemainingTime)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                
                Text("예상 도착")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }
    
    /// 진행 상태 바
    private var progressBar: some View {
        VStack(spacing: 8) {
            // 프로그레스 바
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 배경 트랙
                    Capsule()
                        .fill(.white.opacity(0.2))
                    
                    // 진행된 부분
                    Capsule()
                        .fill(progressGradient)
                        .frame(width: geometry.size.width * state.status.progress)
                        .animation(.spring(response: 0.5), value: state.status.progress)
                    
                    // 진행 인디케이터 (배달원 위치)
                    if state.status == .pickedUp {
                        Circle()
                            .fill(.white)
                            .frame(width: 12, height: 12)
                            .shadow(color: .black.opacity(0.3), radius: 2)
                            .offset(x: geometry.size.width * state.status.progress - 6)
                            .animation(.spring(response: 0.5), value: state.status.progress)
                    }
                }
            }
            .frame(height: 6)
            
            // 단계 라벨
            HStack {
                Text("주문")
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.5))
                
                Spacer()
                
                Text("조리")
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.5))
                
                Spacer()
                
                Text("배달")
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.5))
                
                Spacer()
                
                Text("도착")
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }
    
    /// 하단 행 - 현재 상태 및 배달원 정보
    private var bottomRow: some View {
        HStack {
            // 현재 상태
            HStack(spacing: 8) {
                Image(systemName: state.status.iconName)
                    .font(.body)
                    .foregroundStyle(statusColor)
                    .symbolEffect(.pulse, isActive: state.status == .pickedUp)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(state.status.rawValue)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                    
                    Text(state.status.description)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            
            Spacer()
            
            // 배달원 정보 (배달 중일 때)
            if let driverName = state.driverName {
                HStack(spacing: 6) {
                    Image(systemName: "person.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .trailing, spacing: 1) {
                        Text(driverName)
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                        
                        Text("배달원")
                            .font(.system(size: 9))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.white.opacity(0.1), in: Capsule())
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// 상태에 따른 색상
    private var statusColor: Color {
        switch state.status {
        case .ordered:
            return .blue
        case .preparing:
            return .orange
        case .ready:
            return .yellow
        case .pickedUp:
            return .green
        case .delivered:
            return .green
        }
    }
    
    /// 진행 바 그라데이션
    private var progressGradient: LinearGradient {
        LinearGradient(
            colors: [.green.opacity(0.8), .green],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Preview

#Preview("주문 접수") {
    LockScreenView(
        attributes: .preview,
        state: .previewOrdered
    )
    .background(.black)
}

#Preview("조리 중") {
    LockScreenView(
        attributes: .preview,
        state: .previewPreparing
    )
    .background(.black)
}

#Preview("배달 중") {
    LockScreenView(
        attributes: .preview,
        state: .previewPickedUp
    )
    .background(.black)
}

#Preview("배달 완료") {
    LockScreenView(
        attributes: .preview,
        state: .previewDelivered
    )
    .background(.black)
}
