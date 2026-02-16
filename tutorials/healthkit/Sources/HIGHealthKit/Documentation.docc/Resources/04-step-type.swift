import HealthKit

// MARK: - 걸음 수 타입 정의

// 걸음 수는 HKQuantityType으로 정의됩니다
let stepCountType = HKQuantityType(.stepCount)

// 또는 HKQuantityTypeIdentifier를 직접 사용
let stepCountType2 = HKQuantityType(
    HKQuantityTypeIdentifier.stepCount
)

// 권한 요청 시 사용
let typesToRead: Set<HKObjectType> = [
    HKQuantityType(.stepCount)
]
