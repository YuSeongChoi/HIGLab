//
//  OrderStatusView.swift
//  DeliveryTracker
//
//  주문 상태를 카드 형태로 표시하는 뷰
//  앱 내에서 현재 주문 상태를 시각적으로 보여줍니다.
//

import SwiftUI

/// 주문 상태 카드 뷰
/// Live Activity와 동일한 정보를 앱 내에서 표시합니다.
struct OrderStatusView: View {
    
    // MARK: - Properties
    
    /// 주문 속성 (정적 데이터)
    let attributes: DeliveryAttributes
    
    /// 현재 상태 (동적 데이터)
    let state: DeliveryState
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 - 음식점 정보
            headerSection
            
            Divider()
                .padding(.horizontal)
            
            // 중단 - 진행 상태
            progressSection
            
            Divider()
                .padding(.horizontal)
            
            // 하단 - 예상 시간 및 배달원 정보
            footerSection
        }
        .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
    
    // MARK: - View Components
    
    /// 헤더 섹션 - 음식점 및 주문 정보
    private var headerSection: some View {
        HStack(spacing: 12) {
            // 음식점 아이콘
            ZStack {
                Circle()
                    .fill(.orange.gradient)
                    .frame(width: 50, height: 50)
                
                Image(systemName: "storefront.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(attributes.restaurantName)
                    .font(.headline)
                
                Text(attributes.orderSummary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // 주문 번호
            VStack(alignment: .trailing, spacing: 2) {
                Text("주문번호")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(attributes.orderNumber.suffix(7))
                    .font(.caption.monospaced())
            }
        }
        .padding()
    }
    
    /// 진행 상태 섹션
    private var progressSection: some View {
        VStack(spacing: 16) {
            // 현재 상태 아이콘 및 텍스트
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(statusColor.gradient)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: state.status.iconName)
                        .font(.title)
                        .foregroundStyle(.white)
                        .symbolEffect(.bounce, value: state.status)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(state.status.rawValue)
                        .font(.title3.bold())
                    
                    Text(state.status.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            // 진행률 바
            ProgressView(value: state.status.progress)
                .tint(statusColor)
                .animation(.easeInOut, value: state.status.progress)
            
            // 단계 표시
            HStack {
                ForEach(DeliveryStatus.allCases, id: \.self) { status in
                    Circle()
                        .fill(statusStepColor(for: status))
                        .frame(width: 10, height: 10)
                    
                    if status != .delivered {
                        Spacer()
                    }
                }
            }
        }
        .padding()
    }
    
    /// 하단 섹션 - 배달 예상 시간 및 배달원 정보
    private var footerSection: some View {
        HStack {
            // 예상 도착 시간
            VStack(alignment: .leading, spacing: 4) {
                Text("예상 도착")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    
                    Text(state.formattedRemainingTime)
                        .font(.title3.bold())
                        .contentTransition(.numericText())
                }
            }
            
            Spacer()
            
            // 배달원 정보 (배달 중일 때만 표시)
            if let driverName = state.driverName {
                HStack(spacing: 8) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("배달원")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(driverName)
                            .font(.subheadline.bold())
                    }
                    
                    Image(systemName: "person.circle.fill")
                        .font(.title)
                        .foregroundStyle(.blue.gradient)
                }
            }
        }
        .padding()
    }
    
    // MARK: - Helper Methods
    
    /// 현재 상태에 따른 색상
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
    
    /// 단계별 색상 결정
    private func statusStepColor(for status: DeliveryStatus) -> Color {
        let currentIndex = DeliveryStatus.allCases.firstIndex(of: state.status) ?? 0
        let statusIndex = DeliveryStatus.allCases.firstIndex(of: status) ?? 0
        
        if statusIndex <= currentIndex {
            return statusColor
        } else {
            return .gray.opacity(0.3)
        }
    }
}

// MARK: - Preview

#Preview("주문 접수") {
    OrderStatusView(
        attributes: .preview,
        state: .previewOrdered
    )
    .padding()
}

#Preview("조리 중") {
    OrderStatusView(
        attributes: .preview,
        state: .previewPreparing
    )
    .padding()
}

#Preview("배달 중") {
    OrderStatusView(
        attributes: .preview,
        state: .previewPickedUp
    )
    .padding()
}

#Preview("배달 완료") {
    OrderStatusView(
        attributes: .preview,
        state: .previewDelivered
    )
    .padding()
}
