import HealthKit

// MARK: - HKSample 구조

/*
 모든 HealthKit 데이터는 HKSample 형태로 저장됩니다
 
 HKSample
 ├── uuid: 고유 식별자
 ├── sampleType: 데이터 타입
 ├── startDate: 시작 시간
 ├── endDate: 종료 시간
 ├── device: 측정 기기 (Apple Watch, iPhone 등)
 └── sourceRevision: 데이터 출처 앱
 
 HKQuantitySample (HKSample 상속)
 └── quantity: HKQuantity (값 + 단위)
 
 HKCategorySample (HKSample 상속)
 └── value: Int (카테고리 열거값)
 */

// 예시: 걸음 수 샘플
// startDate: 2024-01-15 09:00:00
// endDate: 2024-01-15 10:00:00
// quantity: 1500 count
// device: Apple Watch Series 9
// source: com.apple.health
