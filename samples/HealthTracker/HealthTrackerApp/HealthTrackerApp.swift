import SwiftUI

// MARK: - 앱 진입점
/// HealthTracker 앱의 메인 진입점
@main
struct HealthTrackerApp: App {
    
    // MARK: - 상태 객체
    @StateObject private var healthViewModel = HealthViewModel()
    
    // MARK: - 바디
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthViewModel)
        }
    }
}

// MARK: - 콘텐츠 뷰
/// 앱의 메인 콘텐츠 뷰
struct ContentView: View {
    @EnvironmentObject var viewModel: HealthViewModel
    
    var body: some View {
        Group {
            if viewModel.isAuthorized {
                // 권한이 승인된 경우 메인 탭 뷰 표시
                MainTabView()
            } else {
                // 권한 요청 화면 표시
                OnboardingView()
            }
        }
        .alert("오류", isPresented: $viewModel.showError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "알 수 없는 오류가 발생했습니다.")
        }
    }
}

// MARK: - 메인 탭 뷰
/// 앱의 메인 탭 네비게이션
struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 대시보드 탭
            DashboardView()
                .tabItem {
                    Label("대시보드", systemImage: "heart.fill")
                }
                .tag(0)
            
            // 활동 탭
            ActivityView()
                .tabItem {
                    Label("활동", systemImage: "figure.walk")
                }
                .tag(1)
            
            // 수면 탭
            SleepView()
                .tabItem {
                    Label("수면", systemImage: "moon.fill")
                }
                .tag(2)
            
            // 운동 탭
            WorkoutView()
                .tabItem {
                    Label("운동", systemImage: "flame.fill")
                }
                .tag(3)
            
            // 통계 탭
            StatisticsView()
                .tabItem {
                    Label("통계", systemImage: "chart.bar.fill")
                }
                .tag(4)
        }
        .tint(.pink)
    }
}

// MARK: - 온보딩 뷰
/// HealthKit 권한 요청을 위한 온보딩 화면
struct OnboardingView: View {
    @EnvironmentObject var viewModel: HealthViewModel
    @State private var isRequestingPermission = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // 앱 아이콘
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(.linearGradient(
                    colors: [.pink, .red],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            
            // 제목
            VStack(spacing: 12) {
                Text("HealthTracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("건강한 삶을 위한 첫 걸음")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            
            // 기능 설명
            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(
                    icon: "figure.walk",
                    title: "활동 추적",
                    description: "걸음 수와 이동 거리를 확인하세요"
                )
                
                FeatureRow(
                    icon: "heart.fill",
                    title: "심박수 모니터링",
                    description: "심박수 변화를 실시간으로 확인하세요"
                )
                
                FeatureRow(
                    icon: "moon.fill",
                    title: "수면 분석",
                    description: "수면 패턴을 분석하고 개선하세요"
                )
                
                FeatureRow(
                    icon: "flame.fill",
                    title: "운동 기록",
                    description: "다양한 운동을 기록하고 관리하세요"
                )
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            // 권한 요청 버튼
            Button {
                requestPermission()
            } label: {
                HStack {
                    if isRequestingPermission {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("시작하기")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.pink)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(isRequestingPermission)
            .padding(.horizontal, 30)
            
            // 개인정보 안내
            Text("건강 데이터는 기기에 안전하게 저장됩니다")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
                .frame(height: 20)
        }
        .background(Color(.systemBackground))
    }
    
    /// 권한 요청 처리
    private func requestPermission() {
        isRequestingPermission = true
        Task {
            await viewModel.requestAuthorization()
            isRequestingPermission = false
        }
    }
}

// MARK: - 기능 설명 행
/// 온보딩 화면의 기능 설명 행
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.pink)
                .frame(width: 44, height: 44)
                .background(Color.pink.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - 프리뷰
#Preview("메인 탭") {
    MainTabView()
        .environmentObject(HealthViewModel())
}

#Preview("온보딩") {
    OnboardingView()
        .environmentObject(HealthViewModel())
}
