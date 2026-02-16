import HealthKit

// MARK: - HealthKit 사용 가능 여부 확인

// HealthKit은 모든 기기에서 사용 가능한 것이 아닙니다
// - ❌ iPad: 지원되지 않음
// - ❌ 일부 iPod touch: 지원되지 않음
// - ✅ iPhone: 완전 지원
// - ✅ Apple Watch: 완전 지원

// 앱 시작 시 반드시 확인하세요
func checkHealthKitAvailability() -> Bool {
    guard HKHealthStore.isHealthDataAvailable() else {
        // HealthKit을 사용할 수 없는 기기
        print("이 기기에서는 HealthKit을 사용할 수 없습니다.")
        return false
    }
    return true
}

// SwiftUI에서 활용 예시
struct ContentView: View {
    var body: some View {
        Group {
            if HKHealthStore.isHealthDataAvailable() {
                DashboardView()
            } else {
                Text("이 기기에서는 건강 데이터를 지원하지 않습니다.")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
