//
//  DeliveryState.swift
//  DeliveryTracker
//
//  Live Activity의 동적 상태(ContentState)를 정의합니다.
//

import Foundation

/// 배달 상태를 나타내는 열거형
/// 각 단계는 배달 과정의 진행 상황을 표현합니다.
enum DeliveryStatus: String, Codable, CaseIterable {
    /// 주문이 접수됨
    case ordered = "주문 접수"
    
    /// 음식점에서 조리 중
    case preparing = "조리 중"
    
    /// 조리 완료, 배달원 대기 중
    case ready = "조리 완료"
    
    /// 배달원이 픽업하여 배달 중
    case pickedUp = "배달 중"
    
    /// 배달 완료
    case delivered = "배달 완료"
    
    /// 현재 상태에 맞는 SF Symbol 아이콘 이름
    var iconName: String {
        switch self {
        case .ordered:
            return "checkmark.circle.fill"
        case .preparing:
            return "frying.pan.fill"
        case .ready:
            return "takeoutbag.and.cup.and.straw.fill"
        case .pickedUp:
            return "bicycle"
        case .delivered:
            return "house.fill"
        }
    }
    
    /// 상태 설명 메시지
    var description: String {
        switch self {
        case .ordered:
            return "주문이 접수되었습니다"
        case .preparing:
            return "음식을 조리하고 있어요"
        case .ready:
            return "음식이 준비되었어요"
        case .pickedUp:
            return "배달원이 출발했어요"
        case .delivered:
            return "배달이 완료되었습니다"
        }
    }
    
    /// 진행률 (0.0 ~ 1.0)
    var progress: Double {
        switch self {
        case .ordered:
            return 0.1
        case .preparing:
            return 0.3
        case .ready:
            return 0.5
        case .pickedUp:
            return 0.8
        case .delivered:
            return 1.0
        }
    }
    
    /// 다음 상태로 전환
    var next: DeliveryStatus? {
        switch self {
        case .ordered:
            return .preparing
        case .preparing:
            return .ready
        case .ready:
            return .pickedUp
        case .pickedUp:
            return .delivered
        case .delivered:
            return nil
        }
    }
}

/// Live Activity의 동적 상태
/// ActivityAttributes.ContentState를 준수합니다.
struct DeliveryState: Codable, Hashable {
    /// 현재 배달 상태
    let status: DeliveryStatus
    
    /// 남은 예상 시간 (분)
    let remainingMinutes: Int
    
    /// 배달원 이름 (배달 중일 때만 표시)
    let driverName: String?
    
    /// 마지막 업데이트 시각
    let lastUpdated: Date
    
    // MARK: - Convenience Initializers
    
    /// 기본 초기화
    init(
        status: DeliveryStatus,
        remainingMinutes: Int,
        driverName: String? = nil,
        lastUpdated: Date = Date()
    ) {
        self.status = status
        self.remainingMinutes = remainingMinutes
        self.driverName = driverName
        self.lastUpdated = lastUpdated
    }
    
    /// 남은 시간을 포맷팅된 문자열로 반환
    var formattedRemainingTime: String {
        if remainingMinutes <= 0 {
            return "곧 도착"
        } else if remainingMinutes < 60 {
            return "\(remainingMinutes)분"
        } else {
            let hours = remainingMinutes / 60
            let mins = remainingMinutes % 60
            return mins > 0 ? "\(hours)시간 \(mins)분" : "\(hours)시간"
        }
    }
}

// MARK: - Preview 지원

#if DEBUG
extension DeliveryState {
    /// 프리뷰용 샘플 상태들
    static var previewOrdered: DeliveryState {
        DeliveryState(status: .ordered, remainingMinutes: 30)
    }
    
    static var previewPreparing: DeliveryState {
        DeliveryState(status: .preparing, remainingMinutes: 25)
    }
    
    static var previewPickedUp: DeliveryState {
        DeliveryState(
            status: .pickedUp,
            remainingMinutes: 10,
            driverName: "김배달"
        )
    }
    
    static var previewDelivered: DeliveryState {
        DeliveryState(status: .delivered, remainingMinutes: 0)
    }
}
#endif
