import HealthKit

// MARK: - HKHealthStore 싱글톤 패턴

// ❌ 피해야 할 패턴: 여러 곳에서 인스턴스 생성
class BadExample {
    let store1 = HKHealthStore()  // 뷰 A
    let store2 = HKHealthStore()  // 뷰 B
    let store3 = HKHealthStore()  // 서비스 C
    // 불필요한 리소스 낭비!
}

// ✅ 권장 패턴: 앱 전체에서 하나의 인스턴스 공유
class HealthManager {
    static let shared = HealthManager()
    
    let healthStore: HKHealthStore
    
    private init() {
        self.healthStore = HKHealthStore()
    }
}

// 사용
let manager = HealthManager.shared
let store = manager.healthStore
