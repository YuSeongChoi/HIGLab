import HealthKit

// MARK: - HealthKit 데이터 타입 분류

// 1. HKQuantityType: 숫자로 측정되는 값
let stepCount = HKQuantityType(.stepCount)           // 걸음 수
let heartRate = HKQuantityType(.heartRate)           // 심박수 (BPM)
let bodyMass = HKQuantityType(.bodyMass)             // 체중
let activeEnergy = HKQuantityType(.activeEnergyBurned) // 활동 칼로리

// 2. HKCategoryType: 카테고리로 분류되는 값
let sleepAnalysis = HKCategoryType(.sleepAnalysis)   // 수면 분석
let mindfulSession = HKCategoryType(.mindfulSession) // 마음 챙김

// 3. HKWorkoutType: 운동 세션
let workoutType = HKWorkoutType.workoutType()        // 모든 운동

// 4. HKCharacteristicType: 사용자 특성 (읽기 전용)
let biologicalSex = HKCharacteristicType(.biologicalSex)
let dateOfBirth = HKCharacteristicType(.dateOfBirth)
