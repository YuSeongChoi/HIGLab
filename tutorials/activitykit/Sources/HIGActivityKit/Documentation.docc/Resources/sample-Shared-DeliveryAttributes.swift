//
//  DeliveryAttributes.swift
//  DeliveryTracker
//
//  ActivityKit Live Activity를 위한 ActivityAttributes 정의
//

import ActivityKit
import Foundation

/// 배달 추적 Live Activity의 속성 정의
/// ActivityAttributes는 Live Activity의 정적(static) 데이터와 동적(dynamic) 데이터를 정의합니다.
struct DeliveryAttributes: ActivityAttributes {
    
    // MARK: - ContentState (동적 데이터)
    
    /// Live Activity가 업데이트될 때마다 변경될 수 있는 동적 상태
    /// 이 데이터는 Activity가 실행되는 동안 여러 번 업데이트될 수 있습니다.
    public typealias ContentState = DeliveryState
    
    // MARK: - Static Properties (정적 데이터)
    
    /// 주문 번호 - Activity 생성 시 설정되며 변경되지 않음
    let orderNumber: String
    
    /// 음식점 이름
    let restaurantName: String
    
    /// 주문 항목 요약 (예: "치킨 버거 외 2개")
    let orderSummary: String
    
    /// 주문 시각
    let orderTime: Date
    
    /// 예상 배달 소요 시간 (분)
    let estimatedDeliveryMinutes: Int
}

// MARK: - Preview 지원

#if DEBUG
extension DeliveryAttributes {
    /// 프리뷰 및 테스트용 샘플 데이터
    static var preview: DeliveryAttributes {
        DeliveryAttributes(
            orderNumber: "ORD-2024-001",
            restaurantName: "맛있는 치킨집",
            orderSummary: "후라이드 치킨 외 2개",
            orderTime: Date(),
            estimatedDeliveryMinutes: 30
        )
    }
}
#endif
