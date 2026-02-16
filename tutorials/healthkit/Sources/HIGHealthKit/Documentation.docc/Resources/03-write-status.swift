import HealthKit

// MARK: - 쓰기 권한 상태 확인

class HealthManager: ObservableObject {
    let healthStore = HKHealthStore()
    
    // 쓰기 권한 상태 확인 (가능)
    func checkWriteAuthorizationStatus() -> HKAuthorizationStatus {
        let stepType = HKQuantityType(.stepCount)
        
        let status = healthStore.authorizationStatus(for: stepType)
        
        switch status {
        case .notDetermined:
            // 아직 권한을 요청하지 않음
            print("권한 요청 필요")
            
        case .sharingAuthorized:
            // 쓰기 권한 승인됨
            print("쓰기 권한 있음")
            
        case .sharingDenied:
            // 쓰기 권한 거부됨
            print("쓰기 권한 거부됨")
            
        @unknown default:
            break
        }
        
        return status
    }
    
    // 여러 타입의 권한 상태 한번에 확인
    func checkAllWriteStatuses() {
        let types: [HKSampleType] = [
            HKQuantityType(.stepCount),
            HKQuantityType(.bodyMass),
            HKWorkoutType.workoutType()
        ]
        
        for type in types {
            let status = healthStore.authorizationStatus(for: type)
            print("\(type): \(status.rawValue)")
        }
    }
}
