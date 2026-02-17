# SubscriptionApp

StoreKit 2를 사용한 구독 관리 샘플 앱입니다.

## 📁 프로젝트 구조

```
SubscriptionApp/
├── Shared/                          # 공유 모듈
│   ├── SubscriptionProduct.swift    # 구독 상품 정의
│   ├── SubscriptionManager.swift    # 구독 관리 (StoreKit 2)
│   └── EntitlementManager.swift     # 자격/권한 관리
│
├── SubscriptionAppMain/             # 메인 앱
│   ├── SubscriptionApp.swift        # @main 진입점
│   ├── ContentView.swift            # 메인 화면
│   ├── PaywallView.swift            # 페이월 (구독 선택)
│   ├── SubscriptionStatusView.swift # 구독 상태 상세
│   └── ManageSubscriptionView.swift # 구독 관리
│
└── README.md
```

## 🎯 주요 기능

### 구독 상품 (SubscriptionProduct)
- **월간 기본** / **월간 프리미엄**
- **연간 기본** / **연간 프리미엄**
- 티어 시스템: 무료 → 기본 → 프리미엄

### 구독 관리자 (SubscriptionManager)
- StoreKit 2 기반 구독 처리
- 실시간 트랜잭션 리스너
- 구매, 복원, 상태 확인
- 자동 검증 (VerificationResult)

### 자격 관리자 (EntitlementManager)
- 구독 티어별 기능 접근 제어
- 기능별 잠금/해제 상태
- `requiresFeature()` 뷰 수정자

## 🔧 StoreKit 2 핵심 API

```swift
// 상품 로드
let products = try await Product.products(for: productIDs)

// 구매
let result = try await product.purchase()

// 현재 자격 확인
for await result in Transaction.currentEntitlements { ... }

// 트랜잭션 업데이트 리스너
for await result in Transaction.updates { ... }

// 구매 복원
try await AppStore.sync()
```

## 📱 화면 설명

### ContentView
- 현재 구독 상태 표시
- 기능별 잠금/해제 목록
- 페이월 또는 관리 화면으로 이동

### PaywallView
- 월간/연간 탭 선택
- 상품별 가격 및 혜택 표시
- 구독 구매 버튼
- 구매 복원 링크

### SubscriptionStatusView
- 현재 구독 상세 정보
- 갱신 상태, 만료일
- 자격 정보 확인
- 문제 해결 옵션

### ManageSubscriptionView
- 플랜 업그레이드/다운그레이드
- 구독 취소 (App Store 이동)

## ⚙️ App Store Connect 설정

1. **구독 그룹 생성**
   - 그룹 ID: `com.higlab.subscription.group`

2. **구독 상품 추가**
   - `com.higlab.subscription.monthly.basic`
   - `com.higlab.subscription.monthly.premium`
   - `com.higlab.subscription.yearly.basic`
   - `com.higlab.subscription.yearly.premium`

3. **StoreKit Configuration 파일**
   - Xcode에서 테스트용 설정 파일 생성
   - 샌드박스 테스트 계정 사용

## 🧪 테스트

### Xcode에서 테스트
1. StoreKit Configuration 파일 생성
2. Scheme에서 StoreKit Configuration 선택
3. 시뮬레이터/기기에서 구독 테스트

### 샌드박스 테스트
- App Store Connect에서 샌드박스 테스터 추가
- 기기 설정 → App Store → 샌드박스 계정

## 📚 참고 자료

- [StoreKit 2 공식 문서](https://developer.apple.com/documentation/storekit)
- [Implementing a store in your app](https://developer.apple.com/documentation/storekit/in-app_purchase/implementing_a_store_in_your_app_using_the_storekit_api)
- [Supporting subscription offer codes](https://developer.apple.com/documentation/storekit/in-app_purchase/original_api_for_in-app_purchase/subscriptions_and_offers/implementing_offer_codes_in_your_app)

## ✅ 체크리스트

- [ ] App Store Connect에 구독 상품 등록
- [ ] 구독 그룹 설정
- [ ] StoreKit Configuration 파일 생성 (테스트용)
- [ ] 샌드박스 테스터 추가
- [ ] 이용약관/개인정보처리방침 URL 설정
- [ ] 구독 안내 문구 검토 (App Review 가이드라인)
