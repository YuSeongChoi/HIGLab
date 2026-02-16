import HealthKit
import SwiftUI

// MARK: - 사용 가능 여부 체크가 포함된 HealthManager

@MainActor
class HealthManager: ObservableObject {
    let healthStore: HKHealthStore?
    
    // HealthKit 사용 가능 여부
    let isHealthKitAvailable: Bool
    
    @Published var isAuthorized = false
    @Published var stepCount: Int = 0
    
    init() {
        // 초기화 시점에 사용 가능 여부 확인
        if HKHealthStore.isHealthDataAvailable() {
            self.healthStore = HKHealthStore()
            self.isHealthKitAvailable = true
        } else {
            self.healthStore = nil
            self.isHealthKitAvailable = false
        }
    }
    
    // 안전하게 HealthStore 사용
    func requestAuthorization() async throws {
        guard let store = healthStore else {
            throw HealthKitError.notAvailable
        }
        // 권한 요청 로직...
    }
}

enum HealthKitError: Error {
    case notAvailable
    case authorizationFailed
}
