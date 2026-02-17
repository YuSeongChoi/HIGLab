import SwiftUI
import TipKit

// MARK: - TipShowcase 앱
// TipKit의 모든 기능을 시연하는 샘플 앱입니다.
// iOS 17+ 필수

@main
struct TipShowcaseApp: App {
    
    // MARK: - 환경 객체
    
    /// TipKit 설정 관리자
    @StateObject private var configManager = TipConfigurationManager.shared
    
    /// 팁 그룹 관리자
    @StateObject private var groupManager = TipGroupManager.shared
    
    /// 팁 통계
    @StateObject private var statistics = TipStatistics.shared
    
    // MARK: - 상태
    
    /// 앱 초기화 완료 여부
    @State private var isInitialized = false
    
    /// 스플래시 화면 표시 여부
    @State private var showSplash = true
    
    // MARK: - 앱 생명주기
    
    @Environment(\.scenePhase) private var scenePhase
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    // 스플래시 화면
                    SplashView()
                        .transition(.opacity)
                } else {
                    // 메인 콘텐츠
                    ContentView()
                        .environmentObject(configManager)
                        .environmentObject(groupManager)
                        .environmentObject(statistics)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showSplash)
            .task {
                // TipKit 초기화
                await initializeTipKit()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            handleScenePhaseChange(newPhase)
        }
    }
    
    // MARK: - TipKit 초기화
    
    /// TipKit을 초기화하고 필요한 설정을 수행합니다.
    private func initializeTipKit() async {
        do {
            // 개발 모드로 TipKit 설정
            #if DEBUG
            try await configManager.configure(with: .development)
            #else
            try await configManager.configure(with: .production)
            #endif
            
            // 파라미터 업데이트
            TipParametersManager.updateOnAppLaunch()
            
            // 앱 실행 이벤트 기록
            await TipEventRecorder.recordAppLaunched()
            
            isInitialized = true
            
            // 스플래시 화면 종료 (최소 1초 표시)
            try? await Task.sleep(for: .seconds(1))
            showSplash = false
            
            print("✅ TipShowcase 앱 초기화 완료")
            
        } catch {
            print("❌ TipKit 초기화 실패: \(error.localizedDescription)")
            // 초기화 실패해도 앱은 계속 실행
            showSplash = false
        }
    }
    
    // MARK: - 앱 생명주기 처리
    
    /// 씬 상태 변경 처리
    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .active:
            // 앱이 활성화됨
            Task {
                await configManager.handleAppBecameActive()
                await TipEventRecorder.recordAppBecameActive()
                TimeBasedParameters.updateCurrentTime()
            }
            print("📱 앱 활성화")
            
        case .inactive:
            // 앱이 비활성화됨
            print("📱 앱 비활성화")
            
        case .background:
            // 앱이 백그라운드로 이동
            configManager.handleAppResignActive()
            print("📱 앱 백그라운드")
            
        @unknown default:
            break
        }
    }
}

// MARK: - 스플래시 뷰

/// 앱 시작 시 표시되는 스플래시 화면
struct SplashView: View {
    
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // 배경 그라데이션
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // 앱 아이콘
                Image(systemName: "lightbulb.max.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.white)
                    .scaleEffect(scale)
                
                // 앱 이름
                Text("TipShowcase")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                // 서브타이틀
                Text("TipKit의 모든 것을 배워보세요")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                
                // 로딩 인디케이터
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(1.2)
                    .padding(.top, 20)
            }
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

// MARK: - 디버그 확장

#if DEBUG
extension TipShowcaseApp {
    
    /// 모든 팁 리셋 (디버그용)
    static func resetAllTips() async {
        await TipConfigurationManager.shared.resetAllTips()
        TipParametersManager.resetAll()
        TipScheduler.shared.clearHistory()
        TipStatistics.shared.reset()
        print("🔄 모든 팁 데이터 리셋 완료")
    }
    
    /// 테스트 모드 활성화 (디버그용)
    static func enableTestMode() {
        TipConfigurationManager.shared.enableTestMode()
        print("🧪 테스트 모드 활성화됨")
    }
    
    /// 디버그 정보 출력
    static func printDebugInfo() {
        TipConfigurationManager.shared.printDebugInfo()
        TipParametersManager.printDebugInfo()
        print(TipStatistics.shared.summary)
    }
}
#endif

// MARK: - 앱 상수

/// 앱 전역 상수
enum AppConstants {
    /// 앱 버전
    static let version = "1.0.0"
    
    /// 빌드 번호
    static let build = "1"
    
    /// 최소 지원 iOS 버전
    static let minimumIOSVersion = "17.0"
    
    /// TipKit 기능 플래그
    enum Features {
        /// 온보딩 팁 활성화
        static let onboardingTipsEnabled = true
        
        /// 이벤트 기반 팁 활성화
        static let eventBasedTipsEnabled = true
        
        /// 시간 기반 팁 활성화
        static let timeBasedTipsEnabled = true
        
        /// 고급 팁 활성화
        static let advancedTipsEnabled = true
    }
}
