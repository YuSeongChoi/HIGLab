import HealthKit
import SwiftUI

// MARK: - 권한 요청이 통합된 HealthManager

@MainActor
class HealthManager: ObservableObject {
    let healthStore = HKHealthStore()
    
    // 권한 상태 (UI 바인딩용)
    @Published var authorizationRequested = false
    @Published var isLoading = false
    
    // 모든 권한 한번에 요청
    func requestAuthorization() async throws {
        isLoading = true
        defer { isLoading = false }
        
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType(.stepCount),
            HKQuantityType(.heartRate),
            HKQuantityType(.activeEnergyBurned),
            HKCategoryType(.sleepAnalysis),
            HKWorkoutType.workoutType()
        ]
        
        let typesToWrite: Set<HKSampleType> = [
            HKQuantityType(.stepCount),
            HKWorkoutType.workoutType()
        ]
        
        try await healthStore.requestAuthorization(
            toShare: typesToWrite,
            read: typesToRead
        )
        
        authorizationRequested = true
        
        // 권한 요청 후 데이터 로드 시작
        await fetchAllData()
    }
    
    // 권한 요청이 필요한지 확인
    func needsAuthorization() async -> Bool {
        let stepType = HKQuantityType(.stepCount)
        let status = healthStore.authorizationStatus(for: stepType)
        
        // 쓰기 권한 상태로 판단 (읽기는 확인 불가)
        return status == .notDetermined
    }
    
    private func fetchAllData() async {
        // 데이터 조회 로직...
    }
}
