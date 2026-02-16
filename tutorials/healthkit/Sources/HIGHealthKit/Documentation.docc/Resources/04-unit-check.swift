import HealthKit

// MARK: - 단위 호환성 확인

// 각 QuantityType은 특정 단위와만 호환됩니다

let stepType = HKQuantityType(.stepCount)
let heartRateType = HKQuantityType(.heartRate)

// 걸음 수는 count 단위
print(stepType.is(compatibleWith: .count()))        // true
print(stepType.is(compatibleWith: .meter()))        // false ❌

// 심박수는 count/min 단위
let bpmUnit = HKUnit.count().unitDivided(by: .minute())
print(heartRateType.is(compatibleWith: bpmUnit))    // true
print(heartRateType.is(compatibleWith: .count()))   // false ❌

// ⚠️ 잘못된 단위로 값을 추출하면 크래시!
func badExample(sample: HKQuantitySample) {
    // 걸음 수 샘플에 meter 단위를 사용하면 런타임 에러
    // sample.quantity.doubleValue(for: .meter()) // 💥 크래시
}

// ✅ 올바른 방법
func goodExample(sample: HKQuantitySample) -> Double {
    return sample.quantity.doubleValue(for: .count())
}
