import HealthKit
import SwiftUI

// MARK: - HealthManager 클래스

@MainActor
class HealthManager: ObservableObject {
    let healthStore = HKHealthStore()
    
    // 권한 상태
    @Published var isAuthorized = false
    
    // 건강 데이터
    @Published var stepCount: Int = 0
    @Published var heartRate: Double = 0
    @Published var sleepHours: Double = 0
    
    // 로딩 상태
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        // 초기화 시 특별한 작업 필요 없음
        // 권한 요청은 나중에 명시적으로 호출
    }
}
