import Foundation
import TipKit

// MARK: - TipKit 설정 및 초기화
// iOS 17+에서 TipKit의 전역 설정을 관리합니다.
// Tips.configure()를 통해 팁 표시 빈도, 데이터 저장 위치 등을 설정합니다.

/// TipKit 설정 옵션
/// 앱의 요구사항에 따라 다양한 설정 조합을 제공합니다.
enum TipConfigurationMode: String, CaseIterable, Identifiable {
    /// 개발/테스트용 - 모든 팁 즉시 표시
    case development
    
    /// 프로덕션 - 일반적인 사용자 경험
    case production
    
    /// 데모 - 모든 팁 강제 표시
    case demo
    
    /// 최소 - 팁 표시 최소화
    case minimal
    
    var id: String { rawValue }
    
    /// 모드별 설명
    var description: String {
        switch self {
        case .development:
            return "개발 모드: 팁이 즉시 표시됩니다"
        case .production:
            return "프로덕션 모드: 일반 사용자 경험"
        case .demo:
            return "데모 모드: 모든 팁 강제 표시"
        case .minimal:
            return "최소 모드: 주간 단위로만 표시"
        }
    }
    
    /// 모드별 아이콘
    var iconName: String {
        switch self {
        case .development: return "hammer.fill"
        case .production: return "shippingbox.fill"
        case .demo: return "play.rectangle.fill"
        case .minimal: return "moon.fill"
        }
    }
    
    /// 모드별 표시 빈도
    var displayFrequency: Tips.ConfigurationOption.DisplayFrequency {
        switch self {
        case .development, .demo:
            return .immediate
        case .production:
            return .daily
        case .minimal:
            return .weekly
        }
    }
}

// MARK: - TipKit 설정 관리자

/// TipKit의 설정과 초기화를 담당하는 관리자
/// 싱글톤 패턴으로 앱 전체에서 일관된 설정을 유지합니다.
@MainActor
final class TipConfigurationManager: ObservableObject {
    
    // MARK: - 싱글톤 인스턴스
    
    /// 공유 인스턴스
    static let shared = TipConfigurationManager()
    
    // MARK: - Published 프로퍼티
    
    /// 현재 설정 모드
    @Published private(set) var currentMode: TipConfigurationMode = .development
    
    /// 초기화 완료 여부
    @Published private(set) var isConfigured: Bool = false
    
    /// 마지막 설정 시간
    @Published private(set) var lastConfiguredAt: Date?
    
    /// 오류 메시지
    @Published var errorMessage: String?
    
    // MARK: - 저장 키
    
    private enum StorageKeys {
        static let configurationMode = "tipkit_configuration_mode"
        static let lastConfiguredAt = "tipkit_last_configured_at"
    }
    
    // MARK: - 초기화
    
    private init() {
        // UserDefaults에서 저장된 모드 복원
        if let savedMode = UserDefaults.standard.string(forKey: StorageKeys.configurationMode),
           let mode = TipConfigurationMode(rawValue: savedMode) {
            currentMode = mode
        }
        
        // 마지막 설정 시간 복원
        if let savedDate = UserDefaults.standard.object(forKey: StorageKeys.lastConfiguredAt) as? Date {
            lastConfiguredAt = savedDate
        }
    }
    
    // MARK: - 설정 메서드
    
    /// TipKit을 지정된 모드로 설정합니다.
    /// - Parameter mode: 설정할 모드
    /// - Throws: TipKit 설정 중 발생한 오류
    func configure(with mode: TipConfigurationMode = .development) async throws {
        currentMode = mode
        
        do {
            // TipKit 설정 옵션 구성
            let options: [Tips.ConfigurationOption] = [
                // 표시 빈도 설정
                .displayFrequency(mode.displayFrequency),
                
                // 데이터스토어 위치 (앱 기본 위치 사용)
                .datastoreLocation(.applicationDefault)
            ]
            
            try Tips.configure(options)
            
            // 데모 모드인 경우 모든 팁 표시
            if mode == .demo {
                Tips.showAllTipsForTesting()
            }
            
            // 상태 업데이트
            isConfigured = true
            lastConfiguredAt = Date()
            errorMessage = nil
            
            // UserDefaults에 저장
            UserDefaults.standard.set(mode.rawValue, forKey: StorageKeys.configurationMode)
            UserDefaults.standard.set(lastConfiguredAt, forKey: StorageKeys.lastConfiguredAt)
            
            print("✅ TipKit 설정 완료: \(mode.rawValue) 모드")
            
        } catch {
            isConfigured = false
            errorMessage = error.localizedDescription
            print("❌ TipKit 설정 실패: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// 모든 팁 데이터를 초기화합니다.
    /// - Returns: 리셋 성공 여부
    @discardableResult
    func resetAllTips() async -> Bool {
        do {
            // 전체 팁 데이터스토어 리셋
            try Tips.resetDatastore()
            
            // 재설정
            try await configure(with: currentMode)
            
            print("✅ 모든 팁이 초기화되었습니다.")
            return true
            
        } catch {
            errorMessage = "팁 초기화 실패: \(error.localizedDescription)"
            print("❌ 팁 초기화 실패: \(error.localizedDescription)")
            return false
        }
    }
    
    /// 테스트 모드를 활성화하여 모든 팁을 표시합니다.
    func enableTestMode() {
        // showAllTipsForTesting()은 모든 팁의 규칙을 무시하고 표시
        Tips.showAllTipsForTesting()
        print("🧪 테스트 모드 활성화: 모든 팁이 표시됩니다.")
    }
    
    /// 팁 표시 빈도를 동적으로 변경합니다.
    /// - Parameter frequency: 새로운 표시 빈도
    func updateDisplayFrequency(_ frequency: Tips.ConfigurationOption.DisplayFrequency) async {
        do {
            try Tips.configure([
                .displayFrequency(frequency)
            ])
            print("✅ 표시 빈도 업데이트: \(frequency)")
        } catch {
            print("❌ 표시 빈도 업데이트 실패: \(error.localizedDescription)")
        }
    }
}

// MARK: - 앱 생명주기 통합

extension TipConfigurationManager {
    
    /// 앱이 포그라운드로 돌아올 때 호출
    func handleAppBecameActive() async {
        // 필요한 경우 팁 상태 업데이트
        // 예: 시간 기반 팁 조건 재확인
        print("📱 앱 활성화: 팁 상태 확인 중...")
    }
    
    /// 앱이 백그라운드로 갈 때 호출
    func handleAppResignActive() {
        // 현재 상태 저장 (필요 시)
        print("📱 앱 비활성화: 팁 상태 저장")
    }
}

// MARK: - 디버그 유틸리티

#if DEBUG
extension TipConfigurationManager {
    
    /// 디버그 정보 출력
    func printDebugInfo() {
        print("""
        
        ===== TipKit 디버그 정보 =====
        현재 모드: \(currentMode.rawValue)
        설정 완료: \(isConfigured)
        마지막 설정: \(lastConfiguredAt?.description ?? "없음")
        오류 메시지: \(errorMessage ?? "없음")
        =============================
        
        """)
    }
    
    /// 각 모드별 설정을 테스트합니다.
    func testAllModes() async {
        for mode in TipConfigurationMode.allCases {
            print("테스트 모드: \(mode.rawValue)")
            do {
                try await configure(with: mode)
                print("  ✅ 성공")
            } catch {
                print("  ❌ 실패: \(error.localizedDescription)")
            }
        }
    }
}
#endif
