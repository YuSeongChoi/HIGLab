// ChatSettings.swift
// 앱 전역 설정 모델
// iOS 26+ | FoundationModels
//
// 앱 전체에 적용되는 설정과 사용자 환경설정 관리

import Foundation
import SwiftUI

// MARK: - 앱 설정

/// 앱 전역 설정
struct AppSettings: Codable, Sendable {
    
    // MARK: - 외관 설정
    
    var appearance: AppearanceSettings
    
    // MARK: - 채팅 설정
    
    var chat: ChatDefaults
    
    // MARK: - 알림 설정
    
    var notifications: NotificationSettings
    
    // MARK: - 개인정보 설정
    
    var privacy: PrivacySettings
    
    // MARK: - 고급 설정
    
    var advanced: AdvancedSettings
    
    // MARK: - 초기화
    
    init(
        appearance: AppearanceSettings = AppearanceSettings(),
        chat: ChatDefaults = ChatDefaults(),
        notifications: NotificationSettings = NotificationSettings(),
        privacy: PrivacySettings = PrivacySettings(),
        advanced: AdvancedSettings = AdvancedSettings()
    ) {
        self.appearance = appearance
        self.chat = chat
        self.notifications = notifications
        self.privacy = privacy
        self.advanced = advanced
    }
    
    // MARK: - 기본 설정
    
    static let `default` = AppSettings()
}

// MARK: - 외관 설정

/// 앱 외관 및 테마 설정
struct AppearanceSettings: Codable, Sendable {
    
    /// 테마 모드
    var themeMode: ThemeMode
    
    /// 액센트 색상
    var accentColorName: String
    
    /// 폰트 크기 배율
    var fontScale: Double
    
    /// 메시지 버블 스타일
    var bubbleStyle: BubbleStyle
    
    /// 애니메이션 활성화
    var enableAnimations: Bool
    
    /// 햅틱 피드백 활성화
    var enableHaptics: Bool
    
    init(
        themeMode: ThemeMode = .system,
        accentColorName: String = "blue",
        fontScale: Double = 1.0,
        bubbleStyle: BubbleStyle = .rounded,
        enableAnimations: Bool = true,
        enableHaptics: Bool = true
    ) {
        self.themeMode = themeMode
        self.accentColorName = accentColorName
        self.fontScale = fontScale
        self.bubbleStyle = bubbleStyle
        self.enableAnimations = enableAnimations
        self.enableHaptics = enableHaptics
    }
}

/// 테마 모드
enum ThemeMode: String, Codable, Sendable, CaseIterable {
    case system     // 시스템 설정 따름
    case light      // 라이트 모드
    case dark       // 다크 모드
    
    var displayName: String {
        switch self {
        case .system: return "시스템"
        case .light: return "라이트"
        case .dark: return "다크"
        }
    }
    
    var iconName: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
    
    /// SwiftUI ColorScheme 변환
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

/// 메시지 버블 스타일
enum BubbleStyle: String, Codable, Sendable, CaseIterable {
    case rounded    // 둥근 모서리
    case sharp      // 각진 모서리
    case bubble     // 말풍선 형태
    case minimal    // 미니멀
    
    var displayName: String {
        switch self {
        case .rounded: return "둥근"
        case .sharp: return "각진"
        case .bubble: return "말풍선"
        case .minimal: return "미니멀"
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .rounded: return 16
        case .sharp: return 4
        case .bubble: return 20
        case .minimal: return 8
        }
    }
}

// MARK: - 채팅 기본값

/// 새 대화의 기본 설정
struct ChatDefaults: Codable, Sendable {
    
    /// 기본 시스템 프롬프트
    var defaultSystemPrompt: String
    
    /// 기본 온도 (창의성)
    var defaultTemperature: Double
    
    /// 기본 최대 토큰 수
    var defaultMaxTokens: Int
    
    /// 기본 스트리밍 사용
    var useStreaming: Bool
    
    /// 자동 제목 생성
    var autoTitle: Bool
    
    /// 기본 도구 사용
    var enableToolsByDefault: Bool
    
    /// 기본 활성화 도구
    var defaultEnabledTools: Set<String>
    
    /// 입력 자동 완성
    var autoComplete: Bool
    
    /// 오타 자동 수정
    var autoCorrect: Bool
    
    /// 키보드 리턴으로 전송
    var sendOnReturn: Bool
    
    init(
        defaultSystemPrompt: String = ConversationSettings.defaultSystemPrompt,
        defaultTemperature: Double = 0.7,
        defaultMaxTokens: Int = 4096,
        useStreaming: Bool = true,
        autoTitle: Bool = true,
        enableToolsByDefault: Bool = true,
        defaultEnabledTools: Set<String> = ["weather", "calculator", "datetime"],
        autoComplete: Bool = true,
        autoCorrect: Bool = true,
        sendOnReturn: Bool = false
    ) {
        self.defaultSystemPrompt = defaultSystemPrompt
        self.defaultTemperature = defaultTemperature
        self.defaultMaxTokens = defaultMaxTokens
        self.useStreaming = useStreaming
        self.autoTitle = autoTitle
        self.enableToolsByDefault = enableToolsByDefault
        self.defaultEnabledTools = defaultEnabledTools
        self.autoComplete = autoComplete
        self.autoCorrect = autoCorrect
        self.sendOnReturn = sendOnReturn
    }
}

// MARK: - 알림 설정

/// 알림 관련 설정
struct NotificationSettings: Codable, Sendable {
    
    /// 알림 활성화
    var enabled: Bool
    
    /// 소리 활성화
    var soundEnabled: Bool
    
    /// 진동 활성화
    var vibrationEnabled: Bool
    
    /// 응답 완료 알림
    var notifyOnComplete: Bool
    
    /// 에러 알림
    var notifyOnError: Bool
    
    init(
        enabled: Bool = true,
        soundEnabled: Bool = true,
        vibrationEnabled: Bool = true,
        notifyOnComplete: Bool = false,
        notifyOnError: Bool = true
    ) {
        self.enabled = enabled
        self.soundEnabled = soundEnabled
        self.vibrationEnabled = vibrationEnabled
        self.notifyOnComplete = notifyOnComplete
        self.notifyOnError = notifyOnError
    }
}

// MARK: - 개인정보 설정

/// 개인정보 및 보안 설정
struct PrivacySettings: Codable, Sendable {
    
    /// 대화 내역 저장
    var saveHistory: Bool
    
    /// 로컬에만 저장
    var localOnly: Bool
    
    /// 스크린샷 방지
    var preventScreenshot: Bool
    
    /// 앱 잠금 활성화
    var appLockEnabled: Bool
    
    /// 앱 잠금 방식
    var lockMethod: LockMethod
    
    /// 자동 삭제 기간 (일, 0이면 비활성화)
    var autoDeleteDays: Int
    
    /// 분석 데이터 수집 동의
    var analyticsEnabled: Bool
    
    init(
        saveHistory: Bool = true,
        localOnly: Bool = true,
        preventScreenshot: Bool = false,
        appLockEnabled: Bool = false,
        lockMethod: LockMethod = .biometric,
        autoDeleteDays: Int = 0,
        analyticsEnabled: Bool = false
    ) {
        self.saveHistory = saveHistory
        self.localOnly = localOnly
        self.preventScreenshot = preventScreenshot
        self.appLockEnabled = appLockEnabled
        self.lockMethod = lockMethod
        self.autoDeleteDays = autoDeleteDays
        self.analyticsEnabled = analyticsEnabled
    }
}

/// 앱 잠금 방식
enum LockMethod: String, Codable, Sendable, CaseIterable {
    case biometric  // Face ID / Touch ID
    case passcode   // 비밀번호
    case both       // 둘 다
    
    var displayName: String {
        switch self {
        case .biometric: return "생체 인증"
        case .passcode: return "비밀번호"
        case .both: return "생체 인증 + 비밀번호"
        }
    }
    
    var iconName: String {
        switch self {
        case .biometric: return "faceid"
        case .passcode: return "lock.fill"
        case .both: return "lock.shield.fill"
        }
    }
}

// MARK: - 고급 설정

/// 고급 설정 (개발자/파워유저용)
struct AdvancedSettings: Codable, Sendable {
    
    /// 디버그 모드
    var debugMode: Bool
    
    /// 토큰 사용량 표시
    var showTokenUsage: Bool
    
    /// 응답 시간 표시
    var showResponseTime: Bool
    
    /// 로그 레벨
    var logLevel: LogLevel
    
    /// 네트워크 타임아웃 (초)
    var networkTimeout: Int
    
    /// 최대 대화 수
    var maxConversations: Int
    
    /// 대화당 최대 메시지 수
    var maxMessagesPerConversation: Int
    
    /// 실험적 기능 활성화
    var experimentalFeatures: Bool
    
    init(
        debugMode: Bool = false,
        showTokenUsage: Bool = true,
        showResponseTime: Bool = false,
        logLevel: LogLevel = .info,
        networkTimeout: Int = 30,
        maxConversations: Int = 100,
        maxMessagesPerConversation: Int = 1000,
        experimentalFeatures: Bool = false
    ) {
        self.debugMode = debugMode
        self.showTokenUsage = showTokenUsage
        self.showResponseTime = showResponseTime
        self.logLevel = logLevel
        self.networkTimeout = networkTimeout
        self.maxConversations = maxConversations
        self.maxMessagesPerConversation = maxMessagesPerConversation
        self.experimentalFeatures = experimentalFeatures
    }
}

/// 로그 레벨
enum LogLevel: String, Codable, Sendable, CaseIterable {
    case verbose    // 모든 로그
    case debug      // 디버그 이상
    case info       // 정보 이상
    case warning    // 경고 이상
    case error      // 에러만
    case none       // 로그 없음
    
    var displayName: String {
        switch self {
        case .verbose: return "상세"
        case .debug: return "디버그"
        case .info: return "정보"
        case .warning: return "경고"
        case .error: return "에러"
        case .none: return "없음"
        }
    }
}

// MARK: - 설정 저장소

/// 설정 저장소 - UserDefaults 기반
@MainActor
@Observable
final class SettingsStore {
    
    // MARK: - 싱글톤
    
    static let shared = SettingsStore()
    
    // MARK: - 현재 설정
    
    private(set) var settings: AppSettings {
        didSet {
            save()
        }
    }
    
    // MARK: - UserDefaults 키
    
    private let settingsKey = "app.settings.v1"
    
    // MARK: - 초기화
    
    private init() {
        // UserDefaults에서 로드
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            self.settings = decoded
        } else {
            self.settings = AppSettings.default
        }
    }
    
    // MARK: - 설정 업데이트
    
    /// 설정 업데이트
    /// - Parameter update: 업데이트 클로저
    func update(_ update: (inout AppSettings) -> Void) {
        var newSettings = settings
        update(&newSettings)
        settings = newSettings
    }
    
    /// 설정 초기화
    func reset() {
        settings = AppSettings.default
    }
    
    // MARK: - 저장/로드
    
    private func save() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: settingsKey)
        }
    }
    
    // MARK: - 단축 접근자
    
    var appearance: AppearanceSettings {
        get { settings.appearance }
        set { settings.appearance = newValue; save() }
    }
    
    var chat: ChatDefaults {
        get { settings.chat }
        set { settings.chat = newValue; save() }
    }
    
    var notifications: NotificationSettings {
        get { settings.notifications }
        set { settings.notifications = newValue; save() }
    }
    
    var privacy: PrivacySettings {
        get { settings.privacy }
        set { settings.privacy = newValue; save() }
    }
    
    var advanced: AdvancedSettings {
        get { settings.advanced }
        set { settings.advanced = newValue; save() }
    }
}

// MARK: - 색상 유틸리티

extension AppearanceSettings {
    
    /// 액센트 색상 가져오기
    var accentColor: Color {
        switch accentColorName {
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "teal": return .teal
        case "indigo": return .indigo
        default: return .blue
        }
    }
    
    /// 사용 가능한 액센트 색상 목록
    static let availableColors: [(name: String, color: Color)] = [
        ("blue", .blue),
        ("purple", .purple),
        ("pink", .pink),
        ("red", .red),
        ("orange", .orange),
        ("yellow", .yellow),
        ("green", .green),
        ("teal", .teal),
        ("indigo", .indigo)
    ]
}
