import HealthKit

// MARK: - 권한 요청할 데이터 타입 정의

// 읽기 권한을 요청할 타입들
let typesToRead: Set<HKObjectType> = [
    // Quantity Types (숫자형)
    HKQuantityType(.stepCount),           // 걸음 수
    HKQuantityType(.heartRate),           // 심박수
    HKQuantityType(.activeEnergyBurned),  // 활동 칼로리
    HKQuantityType(.distanceWalkingRunning), // 이동 거리
    
    // Category Types (카테고리형)
    HKCategoryType(.sleepAnalysis),       // 수면 분석
    
    // Workout
    HKWorkoutType.workoutType()           // 운동 기록
]

// 쓰기 권한을 요청할 타입들
let typesToWrite: Set<HKSampleType> = [
    HKQuantityType(.stepCount),           // 걸음 수 기록
    HKQuantityType(.bodyMass),            // 체중 기록
    HKWorkoutType.workoutType()           // 운동 저장
]

// 💡 팁: 앱에서 실제로 사용할 타입만 요청하세요
// 불필요한 권한 요청은 사용자 신뢰를 떨어뜨립니다
