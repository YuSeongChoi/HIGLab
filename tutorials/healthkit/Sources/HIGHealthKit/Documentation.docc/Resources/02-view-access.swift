import SwiftUI

// MARK: - View에서 HealthManager 접근

struct DashboardView: View {
    // @EnvironmentObject로 HealthManager 접근
    @EnvironmentObject var healthManager: HealthManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 걸음 수 카드
                    StepsCard(steps: healthManager.stepCount)
                    
                    // 심박수 카드
                    HeartRateCard(bpm: healthManager.heartRate)
                    
                    // 수면 카드
                    SleepCard(hours: healthManager.sleepHours)
                }
                .padding()
            }
            .navigationTitle("피트니스")
            .task {
                // 뷰가 나타날 때 데이터 로드
                await healthManager.fetchTodayData()
            }
        }
    }
}

// 하위 뷰에서도 동일하게 접근 가능
struct StepsCard: View {
    let steps: Int
    
    var body: some View {
        VStack {
            Image(systemName: "figure.walk")
            Text("\(steps)")
                .font(.largeTitle.bold())
            Text("걸음")
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
