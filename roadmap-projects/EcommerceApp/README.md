# 🛒 EcommerceApp

실제 이커머스 앱처럼 동작하는 통합 샘플 프로젝트입니다.

## 사용 프레임워크

| 프레임워크 | 용도 |
|-----------|------|
| **SwiftUI** | 선언적 UI |
| **SwiftData** | 로컬 데이터 저장 (장바구니, 주문 내역) |
| **StoreKit 2** | 인앱 결제, 구독 |
| **PassKit** | Apple Pay 결제 |
| **CloudKit** | iCloud 동기화 |

## 주요 기능

- 📦 상품 카탈로그 브라우징
- 🛒 장바구니 관리 (SwiftData)
- 💳 Apple Pay 결제 (PassKit)
- 💰 프리미엄 구독 (StoreKit 2)
- ☁️ 기기 간 동기화 (CloudKit)

## 프로젝트 구조

```
EcommerceApp/
├── EcommerceAppApp.swift      # 앱 진입점
├── Models/
│   ├── Product.swift          # 상품 모델
│   ├── CartItem.swift         # 장바구니 아이템
│   └── Order.swift            # 주문 모델
├── Views/
│   ├── ProductListView.swift  # 상품 목록
│   ├── ProductDetailView.swift# 상품 상세
│   ├── CartView.swift         # 장바구니
│   └── SubscriptionView.swift # 구독 관리
├── Managers/
│   ├── StoreManager.swift     # StoreKit 관리
│   ├── PaymentManager.swift   # Apple Pay 관리
│   └── CloudManager.swift     # CloudKit 동기화
└── Info.plist
```

## 필요 권한 & Capabilities

- In-App Purchase capability
- Apple Pay capability
- iCloud (CloudKit) capability

## 실행 방법

1. Xcode에서 프로젝트 열기
2. Team 설정 및 Bundle ID 변경
3. Capabilities 설정 (In-App Purchase, Apple Pay, iCloud)
4. StoreKit Configuration 파일 추가 (테스트용)

## 학습 포인트

1. **SwiftData + CloudKit 통합**: `@Model` 매크로와 iCloud 동기화
2. **StoreKit 2 async/await**: 최신 구독 API 활용
3. **PassKit 결제 플로우**: Apple Pay 버튼부터 완료까지
