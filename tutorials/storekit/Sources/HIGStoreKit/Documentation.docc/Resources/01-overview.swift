import StoreKit

// MARK: - StoreKit 2 주요 타입

/*
 Product: 상품 정보 (가격, 설명 등)
 Transaction: 구매 트랜잭션
 Transaction.currentEntitlements: 현재 권한
 AppStore: 앱스토어 관련 유틸리티
*/

// 상품 타입
enum ProductType {
    case consumable      // 소모품 (코인, 보석)
    case nonConsumable   // 비소모품 (광고 제거, 프리미엄)
    case autoRenewable   // 자동 갱신 구독 (월간/연간)
    case nonRenewable    // 비자동 갱신 구독 (시즌 패스)
}

// HIG 가이드라인
/*
 1. 명확한 가치 전달: 구매 전 기능 미리보기
 2. 투명한 가격: 현지 통화로 명확히 표시
 3. 쉬운 복원: "구매 복원" 버튼 제공
 4. 구독 관리: 설정 > 구독으로 쉽게 이동
*/
