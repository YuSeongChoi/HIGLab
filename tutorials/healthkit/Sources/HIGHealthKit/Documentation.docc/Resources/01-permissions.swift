import HealthKit

// MARK: - 읽기 vs 쓰기 권한

// ⚠️ 핵심: 읽기와 쓰기 권한은 완전히 분리되어 있습니다

let healthStore = HKHealthStore()

// 읽기 권한: 다른 앱이 기록한 데이터를 읽을 수 있음
let readTypes: Set<HKObjectType> = [
    HKQuantityType(.stepCount),
    HKQuantityType(.heartRate),
    HKCategoryType(.sleepAnalysis)
]

// 쓰기 권한: 이 앱에서 데이터를 기록할 수 있음
let writeTypes: Set<HKSampleType> = [
    HKQuantityType(.stepCount),
    HKQuantityType(.bodyMass)
]

// 권한 요청 시 읽기/쓰기를 각각 지정
// toShare = 쓰기 권한
// read = 읽기 권한
Task {
    try await healthStore.requestAuthorization(
        toShare: writeTypes,
        read: readTypes
    )
}
