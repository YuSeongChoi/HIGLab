import SwiftUI
import HealthKit

// MARK: - Just-in-time 권한 요청

// ✅ 권장: 기능을 사용하는 시점에 권한 요청

struct DashboardView: View {
    @EnvironmentObject var healthManager: HealthManager
    @State private var showingSteps = false
    
    var body: some View {
        NavigationStack {
            List {
                // 사용자가 "걸음 수 보기"를 탭했을 때 권한 요청
                Button("걸음 수 보기") {
                    Task {
                        // 먼저 권한 요청
                        await healthManager.requestStepsAuthorization()
                        // 그 다음 화면 전환
                        showingSteps = true
                    }
                }
                
                Button("심박수 보기") {
                    Task {
                        await healthManager.requestHeartRateAuthorization()
                    }
                }
            }
            .navigationDestination(isPresented: $showingSteps) {
                StepsDetailView()
            }
        }
    }
}

// HealthManager에서 기능별 권한 요청 메서드
extension HealthManager {
    func requestStepsAuthorization() async {
        let stepType = HKQuantityType(.stepCount)
        try? await healthStore.requestAuthorization(
            toShare: nil,
            read: [stepType]
        )
    }
    
    func requestHeartRateAuthorization() async {
        let heartRateType = HKQuantityType(.heartRate)
        try? await healthStore.requestAuthorization(
            toShare: nil,
            read: [heartRateType]
        )
    }
}
