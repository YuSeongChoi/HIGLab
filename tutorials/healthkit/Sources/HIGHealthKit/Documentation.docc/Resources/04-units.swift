import HealthKit

// MARK: - HKUnit 이해하기

// 걸음 수의 단위: count (개수)
let countUnit = HKUnit.count()

// 심박수의 단위: count/minute (BPM)
let bpmUnit = HKUnit.count().unitDivided(by: .minute())

// 거리의 단위: meter, kilometer
let meterUnit = HKUnit.meter()
let kmUnit = HKUnit.meterUnit(with: .kilo)

// 칼로리의 단위: kilocalorie
let kcalUnit = HKUnit.kilocalorie()

// 체중의 단위: kilogram, pound
let kgUnit = HKUnit.gramUnit(with: .kilo)
let lbUnit = HKUnit.pound()

// 사용 예시: 걸음 수 값 추출
func extractStepCount(from sample: HKQuantitySample) -> Double {
    // quantity.doubleValue(for:)로 값을 추출
    return sample.quantity.doubleValue(for: .count())
}
