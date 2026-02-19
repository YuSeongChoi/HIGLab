#if canImport(PermissionKit)
import PermissionKit
import HealthKit

// 접근할 건강 데이터 유형 정의
struct HealthDataTypes {
    
    // MARK: - 읽기 전용 데이터 유형
    
    /// 앱에서 읽을 건강 데이터
    static var readTypes: Set<HKObjectType> {
        Set([
            // 활동 데이터
            HKQuantityType(.stepCount),
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.activeEnergyBurned),
            
            // 심장 데이터
            HKQuantityType(.heartRate),
            HKQuantityType(.restingHeartRate),
            HKQuantityType(.heartRateVariabilitySDNN),
            
            // 수면 데이터
            HKCategoryType(.sleepAnalysis),
            
            // 신체 측정
            HKQuantityType(.height),
            HKQuantityType(.bodyMass),
        ])
    }
    
    // MARK: - 쓰기 데이터 유형
    
    /// 앱에서 저장할 건강 데이터
    static var writeTypes: Set<HKSampleType> {
        Set([
            // 운동 기록
            HKQuantityType(.stepCount),
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.activeEnergyBurned),
            
            // 운동 세션
            HKWorkoutType.workoutType(),
        ])
    }
    
    // MARK: - 최소 필수 데이터
    
    /// 앱의 핵심 기능에 필요한 최소 데이터
    static var essentialReadTypes: Set<HKObjectType> {
        Set([
            HKQuantityType(.stepCount),
            HKQuantityType(.activeEnergyBurned),
        ])
    }
}

// iOS 26 PermissionKit - HIG Lab
#endif
