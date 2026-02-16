import SwiftUI

// MARK: - 온보딩에서 설명 후 권한 요청

struct OnboardingView: View {
    @EnvironmentObject var healthManager: HealthManager
    @State private var currentPage = 0
    
    var body: some View {
        TabView(selection: $currentPage) {
            // 페이지 1: 앱 소개
            OnboardingPage(
                image: "figure.run",
                title: "피트니스 대시보드",
                description: "모든 건강 데이터를 한눈에"
            )
            .tag(0)
            
            // 페이지 2: 어떤 데이터를 사용하는지 설명
            OnboardingPage(
                image: "heart.fill",
                title: "건강 데이터 활용",
                description: "걸음 수, 심박수, 수면 데이터를 분석하여\n맞춤형 인사이트를 제공합니다."
            )
            .tag(1)
            
            // 페이지 3: 권한 요청
            VStack(spacing: 24) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green)
                
                Text("권한이 필요합니다")
                    .font(.title.bold())
                
                Text("건강 앱의 데이터에 접근하려면\n아래 버튼을 눌러 권한을 허용해주세요.")
                    .multilineTextAlignment(.center)
                
                Button("권한 허용하기") {
                    Task {
                        try? await healthManager.requestAuthorization()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .tag(2)
        }
        .tabViewStyle(.page)
    }
}

struct OnboardingPage: View {
    let image: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: image)
                .font(.system(size: 80))
            Text(title).font(.title.bold())
            Text(description)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
