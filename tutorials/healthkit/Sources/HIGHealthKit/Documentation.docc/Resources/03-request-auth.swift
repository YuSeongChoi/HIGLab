import HealthKit

// MARK: - 권한 요청 (requestAuthorization)

class HealthManager: ObservableObject {
    let healthStore = HKHealthStore()
    
    // async/await 방식 (권장)
    func requestAuthorization() async throws {
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType(.stepCount),
            HKQuantityType(.heartRate),
            HKCategoryType(.sleepAnalysis)
        ]
        
        let typesToWrite: Set<HKSampleType> = [
            HKQuantityType(.stepCount)
        ]
        
        // toShare: 쓰기 권한
        // read: 읽기 권한
        try await healthStore.requestAuthorization(
            toShare: typesToWrite,
            read: typesToRead
        )
    }
    
    // completion handler 방식 (레거시)
    func requestAuthorizationLegacy(completion: @escaping (Bool, Error?) -> Void) {
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType(.stepCount)
        ]
        
        healthStore.requestAuthorization(
            toShare: nil,
            read: typesToRead
        ) { success, error in
            completion(success, error)
        }
    }
}
