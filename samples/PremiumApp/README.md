# PremiumApp

StoreKit 2를 활용한 인앱 구매 샘플 앱입니다.

## 📁 프로젝트 구조

```
PremiumApp/
├── Shared/
│   ├── ProductItem.swift      # Product 래퍼 구조체
│   ├── StoreManager.swift     # StoreKit 2 관리자
│   └── PurchaseState.swift    # 구매/구독 상태 열거형
│
├── PremiumAppMain/
│   ├── PremiumApp.swift       # @main 앱 진입점
│   ├── ContentView.swift      # 메인 콘텐츠 (무료/프리미엄 분기)
│   ├── StoreView.swift        # 상품 목록 및 구매
│   ├── SubscriptionView.swift # 구독 플랜 관리
│   └── PurchaseHistoryView.swift # 구매 내역
│
└── README.md
```

## ✨ 주요 기능

### 상품 유형 지원
- **비소모성 (Non-Consumable)**: 한 번 구매, 영구 소유 (예: 프리미엄 언락)
- **소모성 (Consumable)**: 여러 번 구매 가능 (예: 게임 코인)
- **자동 갱신 구독**: 월간/연간 구독 플랜

### 핵심 구현
- ✅ StoreKit 2 async/await API 사용
- ✅ 영수증 자동 검증 (VerificationResult)
- ✅ 트랜잭션 업데이트 실시간 감시
- ✅ 구매 복원 (App Store 동기화)
- ✅ 구독 상태 관리 (만료, 유예 기간 등)
- ✅ 구매 내역 조회

## 🛠 설정 방법

### 1. Xcode 프로젝트 설정
```
Signing & Capabilities → + Capability → In-App Purchase
```

### 2. StoreKit Configuration 파일 생성 (테스트용)
```
File → New → File → StoreKit Configuration File
```

### 3. 상품 ID 등록
`ProductItem.ProductID`에 정의된 ID를 App Store Connect 또는 StoreKit Configuration에 등록:

```swift
// 비소모성
com.higlab.premiumapp.premium_unlock
com.higlab.premiumapp.pro_features

// 소모성
com.higlab.premiumapp.coins_100
com.higlab.premiumapp.coins_500

// 구독
com.higlab.premiumapp.subscription_monthly
com.higlab.premiumapp.subscription_yearly
```

## 📝 주요 코드 설명

### StoreManager 사용법

```swift
// 상품 로드
await StoreManager.shared.loadProducts()

// 구매
let success = await StoreManager.shared.purchase(product)

// 복원
await StoreManager.shared.restorePurchases()

// 프리미엄 여부 확인
if StoreManager.shared.isPremium {
    // 프리미엄 기능 활성화
}
```

### 구독 상태 확인

```swift
// 현재 구독 상태
switch StoreManager.shared.subscriptionStatus {
case .active:
    // 구독 중
case .expired:
    // 만료됨
case .none:
    // 구독 없음
// ...
}
```

## 🔒 보안 고려사항

1. **서버 검증**: 프로덕션에서는 서버에서 영수증을 추가 검증하세요
2. **Entitlement 동기화**: 중요한 기능은 서버와 동기화하여 관리하세요
3. **탈옥 감지**: 민감한 앱은 탈옥 기기 감지를 고려하세요

## 📚 참고 자료

- [StoreKit 2 공식 문서](https://developer.apple.com/documentation/storekit/in-app_purchase)
- [WWDC21: Meet StoreKit 2](https://developer.apple.com/videos/play/wwdc2021/10114/)
- [WWDC22: What's new in StoreKit](https://developer.apple.com/videos/play/wwdc2022/10007/)
- [App Store Server API](https://developer.apple.com/documentation/appstoreserverapi)

## 🧪 테스트

### Sandbox 테스트
1. App Store Connect에서 Sandbox 테스터 계정 생성
2. 기기 설정 → App Store → Sandbox 계정으로 로그인
3. 앱에서 구매 테스트

### Xcode 테스트
1. StoreKit Configuration 파일 사용
2. Edit Scheme → Options → StoreKit Configuration 선택
3. 시뮬레이터에서 테스트 (결제 없이 구매 가능)

---

**HIG Lab** - Human Interface Guidelines 학습 프로젝트
