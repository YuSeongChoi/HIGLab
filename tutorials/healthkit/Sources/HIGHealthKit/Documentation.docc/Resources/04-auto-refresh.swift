import SwiftUI

// MARK: - View가 나타날 때 자동 새로고침

struct DashboardView: View {
    @EnvironmentObject var healthManager: HealthManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 걸음 수 카드
                    StepsRingView(steps: healthManager.todaySteps)
                    
                    // 로딩 인디케이터
                    if healthManager.isLoading {
                        ProgressView()
                    }
                }
                .padding()
            }
            .navigationTitle("피트니스")
            .toolbar {
                // 수동 새로고침 버튼
                Button {
                    Task {
                        await healthManager.fetchTodaySteps()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
            // ✅ View가 나타날 때 자동으로 데이터 로드
            .task {
                await healthManager.fetchTodaySteps()
            }
            // 앱이 포그라운드로 돌아올 때도 새로고침
            .onReceive(NotificationCenter.default.publisher(
                for: UIApplication.willEnterForegroundNotification
            )) { _ in
                Task {
                    await healthManager.fetchTodaySteps()
                }
            }
        }
    }
}
