import SwiftUI
import SwiftData
import ShazamKit

// MARK: - SoundMatchApp
/// ShazamKit 음악 인식 앱의 진입점
/// SwiftData, MusicKit, ShazamKit 통합 설정

@main
struct SoundMatchApp: App {
    // MARK: - 상태 객체
    /// Shazam 엔진 (SHSession/SHSessionDelegate 기반)
    @State private var shazamEngine = ShazamEngine()
    
    /// 히스토리 저장소 (SwiftData 기반)
    @State private var historyStore = HistoryStore.shared
    
    /// MusicKit 서비스
    @State private var musicKitService = MusicKitService.shared
    
    /// Shazam 라이브러리 서비스
    @State private var shazamLibraryService = ShazamLibraryService.shared
    
    /// 시그니처 매니저
    @State private var signatureManager = SignatureManager.shared
    
    /// 커스텀 카탈로그 매니저
    @State private var catalogManager = CustomCatalogManager.shared
    
    /// 앱 설정
    @State private var appSettings = AppSettings.shared
    
    // MARK: - SwiftData 컨테이너
    var modelContainer: ModelContainer? {
        historyStore.container
    }
    
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            ContentView()
                // 환경 객체 주입
                .environment(shazamEngine)
                .environment(historyStore)
                .environment(musicKitService)
                .environment(shazamLibraryService)
                .environment(signatureManager)
                .environment(catalogManager)
                .environment(appSettings)
                // SwiftData 컨텍스트 주입
                .modelContainer(for: MatchedSongModel.self)
                // 초기화 작업
                .task {
                    await initializeApp()
                }
        }
    }
    
    // MARK: - 초기화
    /// 앱 초기화 작업
    private func initializeApp() async {
        // MusicKit 권한 요청
        if appSettings.requestMusicKitOnLaunch {
            _ = await musicKitService.requestAuthorization()
        }
        
        // Shazam 라이브러리 동기화 (자동 동기화 활성화 시)
        if shazamLibraryService.autoSyncEnabled {
            await shazamLibraryService.sync()
        }
        
        // 히스토리 새로고침
        await historyStore.refresh()
    }
}

// MARK: - AppSettings
/// 앱 설정 관리

@MainActor
@Observable
final class AppSettings {
    // MARK: - 싱글톤
    static let shared = AppSettings()
    
    // MARK: - UserDefaults 키
    private enum Keys {
        static let hapticFeedback = "hapticFeedbackEnabled"
        static let autoStopOnMatch = "autoStopOnMatch"
        static let showGenreTags = "showGenreTags"
        static let requestMusicKitOnLaunch = "requestMusicKitOnLaunch"
        static let preferCustomCatalog = "preferCustomCatalog"
        static let offlineMode = "offlineMode"
        static let lastUsedCatalogID = "lastUsedCatalogID"
        static let appearance = "appearance"
        static let listenDuration = "listenDuration"
    }
    
    // MARK: - 설정 프로퍼티
    /// 햅틱 피드백 활성화
    var hapticFeedbackEnabled: Bool {
        get { UserDefaults.standard.object(forKey: Keys.hapticFeedback) as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: Keys.hapticFeedback) }
    }
    
    /// 매칭 후 자동 중지
    var autoStopOnMatch: Bool {
        get { UserDefaults.standard.object(forKey: Keys.autoStopOnMatch) as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: Keys.autoStopOnMatch) }
    }
    
    /// 장르 태그 표시
    var showGenreTags: Bool {
        get { UserDefaults.standard.object(forKey: Keys.showGenreTags) as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: Keys.showGenreTags) }
    }
    
    /// 앱 시작 시 MusicKit 권한 요청
    var requestMusicKitOnLaunch: Bool {
        get { UserDefaults.standard.object(forKey: Keys.requestMusicKitOnLaunch) as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: Keys.requestMusicKitOnLaunch) }
    }
    
    /// 커스텀 카탈로그 우선 사용
    var preferCustomCatalog: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.preferCustomCatalog) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.preferCustomCatalog) }
    }
    
    /// 오프라인 모드
    var offlineMode: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.offlineMode) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.offlineMode) }
    }
    
    /// 마지막 사용한 카탈로그 ID
    var lastUsedCatalogID: String? {
        get { UserDefaults.standard.string(forKey: Keys.lastUsedCatalogID) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.lastUsedCatalogID) }
    }
    
    /// 앱 외관 (시스템/라이트/다크)
    var appearance: AppAppearance {
        get {
            let rawValue = UserDefaults.standard.integer(forKey: Keys.appearance)
            return AppAppearance(rawValue: rawValue) ?? .system
        }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: Keys.appearance) }
    }
    
    /// 인식 지속 시간 (초)
    var listenDuration: Int {
        get { UserDefaults.standard.object(forKey: Keys.listenDuration) as? Int ?? 10 }
        set { UserDefaults.standard.set(newValue, forKey: Keys.listenDuration) }
    }
    
    // MARK: - 초기화
    private init() {}
    
    // MARK: - 설정 초기화
    /// 모든 설정을 기본값으로 초기화
    func resetToDefaults() {
        hapticFeedbackEnabled = true
        autoStopOnMatch = true
        showGenreTags = true
        requestMusicKitOnLaunch = true
        preferCustomCatalog = false
        offlineMode = false
        lastUsedCatalogID = nil
        appearance = .system
        listenDuration = 10
    }
}

// MARK: - AppAppearance
/// 앱 외관 설정

enum AppAppearance: Int, CaseIterable, Identifiable {
    case system = 0
    case light = 1
    case dark = 2
    
    var id: Int { rawValue }
    
    var displayName: String {
        switch self {
        case .system: return "시스템"
        case .light: return "라이트"
        case .dark: return "다크"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// MARK: - 색상 스키마 수정자
extension View {
    /// AppAppearance에 따른 색상 스키마 적용
    @ViewBuilder
    func preferredColorScheme(for appearance: AppAppearance) -> some View {
        if let scheme = appearance.colorScheme {
            self.preferredColorScheme(scheme)
        } else {
            self
        }
    }
}
