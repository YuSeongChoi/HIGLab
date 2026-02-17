import Foundation
import SwiftUI

// MARK: - 알림 설정 모델
// 사용자가 커스터마이징할 수 있는 알림 설정을 관리합니다.
// 배지, 사운드, 배너 스타일 등을 세밀하게 제어할 수 있습니다.

/// 앱 전체 알림 설정
struct NotificationSettings: Codable {
    // MARK: - 기본 설정
    
    /// 알림 활성화 여부
    var isEnabled: Bool = true
    
    /// 배지 표시 여부
    var showBadge: Bool = true
    
    /// 사운드 재생 여부
    var playSound: Bool = true
    
    /// 선택된 사운드
    var soundType: SoundType = .default
    
    /// 배너 스타일
    var bannerStyle: BannerStyle = .banner
    
    /// 잠금 화면 표시 여부
    var showOnLockScreen: Bool = true
    
    /// 알림 센터 표시 여부
    var showInNotificationCenter: Bool = true
    
    // MARK: - 방해 금지 설정
    
    /// 조용한 시간 활성화 여부
    var quietHoursEnabled: Bool = false
    
    /// 조용한 시간 시작 (시:분)
    var quietHoursStart: DateComponents = DateComponents(hour: 22, minute: 0)
    
    /// 조용한 시간 종료 (시:분)
    var quietHoursEnd: DateComponents = DateComponents(hour: 7, minute: 0)
    
    // MARK: - 카테고리별 설정
    
    /// 카테고리별 활성화 상태
    var categorySettings: [NotificationCategory: Bool] = [
        .reminder: true,
        .health: true,
        .work: true,
        .social: true,
        .location: true
    ]
    
    // MARK: - 기본값
    
    static let `default` = NotificationSettings()
}

// MARK: - 사운드 타입

/// 알림 사운드 종류
enum SoundType: String, CaseIterable, Codable {
    case `default` = "기본"
    case chime = "차임"
    case bell = "종소리"
    case alert = "경고음"
    case soft = "부드러운"
    case none = "없음"
    
    /// 사운드 파일 이름
    var fileName: String? {
        switch self {
        case .default: nil  // 시스템 기본 사운드
        case .chime: "chime.wav"
        case .bell: "bell.wav"
        case .alert: "alert.wav"
        case .soft: "soft.wav"
        case .none: nil
        }
    }
    
    /// 아이콘
    var symbol: String {
        switch self {
        case .default: "speaker.wave.2"
        case .chime: "music.note"
        case .bell: "bell"
        case .alert: "exclamationmark.triangle"
        case .soft: "leaf"
        case .none: "speaker.slash"
        }
    }
}

// MARK: - 배너 스타일

/// 알림 배너 표시 방식
enum BannerStyle: String, CaseIterable, Codable {
    case none = "없음"
    case banner = "배너"
    case persistent = "지속 배너"
    
    /// 설명
    var description: String {
        switch self {
        case .none: "배너를 표시하지 않습니다"
        case .banner: "일시적으로 표시 후 사라집니다"
        case .persistent: "직접 닫을 때까지 유지됩니다"
        }
    }
    
    /// 아이콘
    var symbol: String {
        switch self {
        case .none: "rectangle.slash"
        case .banner: "rectangle.topthird.inset.filled"
        case .persistent: "rectangle.inset.filled"
        }
    }
}

// MARK: - 설정 저장소

/// 설정을 UserDefaults에 저장하고 불러오는 매니저
@MainActor
class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    private let settingsKey = "NotificationSettings"
    
    @Published var settings: NotificationSettings {
        didSet {
            saveSettings()
        }
    }
    
    private init() {
        self.settings = Self.loadSettings()
    }
    
    /// 설정 저장
    private func saveSettings() {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        UserDefaults.standard.set(data, forKey: settingsKey)
    }
    
    /// 설정 불러오기
    private static func loadSettings() -> NotificationSettings {
        guard let data = UserDefaults.standard.data(forKey: "NotificationSettings"),
              let settings = try? JSONDecoder().decode(NotificationSettings.self, from: data)
        else {
            return .default
        }
        return settings
    }
    
    /// 조용한 시간인지 확인
    func isQuietHours() -> Bool {
        guard settings.quietHoursEnabled else { return false }
        
        let calendar = Calendar.current
        let now = Date()
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentTime = currentHour * 60 + currentMinute
        
        let startTime = (settings.quietHoursStart.hour ?? 22) * 60 + (settings.quietHoursStart.minute ?? 0)
        let endTime = (settings.quietHoursEnd.hour ?? 7) * 60 + (settings.quietHoursEnd.minute ?? 0)
        
        // 시작 > 종료인 경우 (예: 22:00 ~ 07:00)
        if startTime > endTime {
            return currentTime >= startTime || currentTime < endTime
        } else {
            return currentTime >= startTime && currentTime < endTime
        }
    }
    
    /// 특정 카테고리가 활성화되어 있는지 확인
    func isCategoryEnabled(_ category: NotificationCategory) -> Bool {
        settings.categorySettings[category] ?? true
    }
    
    /// 설정 초기화
    func resetToDefaults() {
        settings = .default
    }
}
