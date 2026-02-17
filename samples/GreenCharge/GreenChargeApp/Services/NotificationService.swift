// NotificationService.swift
// GreenCharge - 알림 서비스
// iOS 26 UserNotifications 활용

import Foundation
import UserNotifications
import Observation

// MARK: - 알림 권한 상태

/// 알림 권한 상태
enum NotificationAuthorizationStatus {
    case notDetermined
    case authorized
    case denied
    case provisional
}

// MARK: - 알림 서비스

/// 청정 에너지 시간대 알림 서비스
@Observable
final class NotificationService: NSObject {
    
    // MARK: - 속성
    
    /// 알림 센터
    private let notificationCenter = UNUserNotificationCenter.current()
    
    /// 권한 상태
    private(set) var authorizationStatus: NotificationAuthorizationStatus = .notDetermined
    
    /// 예약된 알림 수
    private(set) var scheduledNotificationCount = 0
    
    /// 에러 메시지
    private(set) var errorMessage: String?
    
    // MARK: - 초기화
    
    override init() {
        super.init()
        
        notificationCenter.delegate = self
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - 권한 관리
    
    /// 권한 상태 확인
    @MainActor
    func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        
        switch settings.authorizationStatus {
        case .notDetermined:
            authorizationStatus = .notDetermined
        case .authorized:
            authorizationStatus = .authorized
        case .denied:
            authorizationStatus = .denied
        case .provisional:
            authorizationStatus = .provisional
        case .ephemeral:
            authorizationStatus = .authorized
        @unknown default:
            authorizationStatus = .notDetermined
        }
        
        await updateScheduledCount()
    }
    
    /// 알림 권한 요청
    @MainActor
    func requestAuthorization() async {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge, .criticalAlert]
            )
            
            authorizationStatus = granted ? .authorized : .denied
        } catch {
            errorMessage = "알림 권한 요청 실패: \(error.localizedDescription)"
            authorizationStatus = .denied
        }
    }
    
    /// 예약된 알림 수 업데이트
    @MainActor
    private func updateScheduledCount() async {
        let requests = await notificationCenter.pendingNotificationRequests()
        scheduledNotificationCount = requests.count
    }
    
    // MARK: - 알림 스케줄링
    
    /// 청정 에너지 시간대 알림 예약
    /// - Parameters:
    ///   - entry: 예보 정보
    ///   - leadTimeMinutes: 미리 알림 시간 (분)
    @MainActor
    func scheduleCleanEnergyAlert(
        for entry: GridForecastEntry,
        leadTimeMinutes: Int = 30
    ) async {
        guard authorizationStatus == .authorized else {
            errorMessage = "알림 권한이 없습니다."
            return
        }
        
        // 알림 시간 계산
        let alertTime = entry.startTime.addingTimeInterval(-Double(leadTimeMinutes * 60))
        
        // 과거 시간이면 스킵
        guard alertTime > Date() else { return }
        
        // 알림 컨텐츠
        let content = UNMutableNotificationContent()
        content.title = "⚡ 청정 에너지 시간 시작!"
        content.body = "곧 청정 에너지 비율이 \(Int(entry.cleanEnergyPercentage * 100))%로 올라갑니다. 충전하기 좋은 시간이에요!"
        content.sound = .default
        content.categoryIdentifier = "CLEAN_ENERGY_ALERT"
        content.userInfo = [
            "type": "cleanEnergy",
            "startTime": entry.startTime.timeIntervalSince1970,
            "cleanPercentage": entry.cleanEnergyPercentage
        ]
        
        // 트리거
        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: alertTime
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // 요청 생성
        let identifier = "cleanEnergy-\(entry.id)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        do {
            try await notificationCenter.add(request)
            await updateScheduledCount()
        } catch {
            errorMessage = "알림 예약 실패: \(error.localizedDescription)"
        }
    }
    
    /// 최적 충전 시간 알림 예약
    /// - Parameter recommendations: 충전 추천 목록
    @MainActor
    func scheduleOptimalChargingAlerts(for recommendations: [ChargingRecommendation]) async {
        guard authorizationStatus == .authorized else { return }
        
        // 기존 최적 충전 알림 삭제
        await removeNotifications(withPrefix: "optimalCharging-")
        
        // 상위 3개 추천에 대해 알림 예약
        for (index, recommendation) in recommendations.prefix(3).enumerated() {
            let alertTime = recommendation.startTime.addingTimeInterval(-1800)  // 30분 전
            
            guard alertTime > Date() else { continue }
            
            let content = UNMutableNotificationContent()
            content.title = "🔋 최적 충전 시간 안내"
            content.body = "\(recommendation.shortTimeString)에 청정도 \(Int(recommendation.estimatedCleanPercentage * 100))% 예상. \(recommendation.reason)"
            content.sound = .default
            content.categoryIdentifier = "OPTIMAL_CHARGING"
            
            let dateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: alertTime
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let identifier = "optimalCharging-\(index)-\(recommendation.id)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            try? await notificationCenter.add(request)
        }
        
        await updateScheduledCount()
    }
    
    /// 일일 요약 알림 설정
    /// - Parameter hour: 알림 시간 (시)
    @MainActor
    func scheduleDailySummary(at hour: Int = 20) async {
        guard authorizationStatus == .authorized else { return }
        
        // 기존 일일 요약 알림 삭제
        await removeNotifications(withPrefix: "dailySummary")
        
        let content = UNMutableNotificationContent()
        content.title = "📊 오늘의 충전 요약"
        content.body = "오늘의 충전 현황과 탄소 절감량을 확인하세요."
        content.sound = .default
        content.categoryIdentifier = "DAILY_SUMMARY"
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "dailySummary",
            content: content,
            trigger: trigger
        )
        
        try? await notificationCenter.add(request)
        await updateScheduledCount()
    }
    
    // MARK: - 알림 관리
    
    /// 특정 접두사로 시작하는 알림 삭제
    @MainActor
    func removeNotifications(withPrefix prefix: String) async {
        let requests = await notificationCenter.pendingNotificationRequests()
        let identifiersToRemove = requests
            .filter { $0.identifier.hasPrefix(prefix) }
            .map { $0.identifier }
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        await updateScheduledCount()
    }
    
    /// 모든 예약된 알림 삭제
    @MainActor
    func removeAllNotifications() async {
        notificationCenter.removeAllPendingNotificationRequests()
        scheduledNotificationCount = 0
    }
    
    /// 테스트 알림 전송
    @MainActor
    func sendTestNotification() async {
        guard authorizationStatus == .authorized else {
            errorMessage = "알림 권한이 없습니다."
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "🧪 테스트 알림"
        content.body = "GreenCharge 알림이 정상적으로 작동합니다!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "test-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        try? await notificationCenter.add(request)
    }
    
    // MARK: - 알림 카테고리 등록
    
    /// 알림 카테고리 및 액션 등록
    func registerNotificationCategories() {
        // 청정 에너지 알림 액션
        let viewAction = UNNotificationAction(
            identifier: "VIEW_ACTION",
            title: "자세히 보기",
            options: .foreground
        )
        
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS_ACTION",
            title: "닫기",
            options: .destructive
        )
        
        // 청정 에너지 카테고리
        let cleanEnergyCategory = UNNotificationCategory(
            identifier: "CLEAN_ENERGY_ALERT",
            actions: [viewAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        // 최적 충전 카테고리
        let startChargingAction = UNNotificationAction(
            identifier: "START_CHARGING",
            title: "충전 시작",
            options: .foreground
        )
        
        let optimalChargingCategory = UNNotificationCategory(
            identifier: "OPTIMAL_CHARGING",
            actions: [startChargingAction, viewAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        // 일일 요약 카테고리
        let dailySummaryCategory = UNNotificationCategory(
            identifier: "DAILY_SUMMARY",
            actions: [viewAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        notificationCenter.setNotificationCategories([
            cleanEnergyCategory,
            optimalChargingCategory,
            dailySummaryCategory
        ])
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    
    /// 앱 포그라운드에서 알림 수신
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .sound, .badge]
    }
    
    /// 알림 응답 처리
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let actionIdentifier = response.actionIdentifier
        let userInfo = response.notification.request.content.userInfo
        
        switch actionIdentifier {
        case "VIEW_ACTION":
            // 앱 열기 및 상세 보기 (앱 내에서 처리)
            break
            
        case "START_CHARGING":
            // 충전 시작 액션 (앱 내에서 처리)
            break
            
        case "DISMISS_ACTION":
            // 알림 닫기
            break
            
        case UNNotificationDefaultActionIdentifier:
            // 알림 탭 (기본 액션)
            break
            
        default:
            break
        }
    }
}
