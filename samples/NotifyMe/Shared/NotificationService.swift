import Foundation
import UserNotifications
import CoreLocation

// MARK: - 알림 서비스
// UNUserNotificationCenter를 래핑하여 로컬/푸시 알림을 관리합니다.
// 시간 기반 및 위치 기반 알림 스케줄링을 지원합니다.

actor NotificationService {
    static let shared = NotificationService()
    
    private let center = UNUserNotificationCenter.current()
    
    // MARK: - 권한 관리
    
    /// 현재 알림 권한 상태 확인
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }
    
    /// 알림 권한 요청
    /// - Returns: 권한 허용 여부
    @discardableResult
    func requestAuthorization() async throws -> Bool {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge, .provisional, .criticalAlert]
        let granted = try await center.requestAuthorization(options: options)
        
        if granted {
            // 권한이 허용되면 카테고리 등록
            await registerCategories()
        }
        
        return granted
    }
    
    /// 알림 카테고리 등록
    /// 카테고리를 등록하면 알림에 액션 버튼을 추가할 수 있습니다.
    func registerCategories() async {
        center.setNotificationCategories(NotificationCategory.allUNCategories)
    }
    
    // MARK: - 알림 스케줄링
    
    /// 시간 기반 알림 스케줄
    /// - Parameters:
    ///   - item: 스케줄할 알림 아이템
    /// - Returns: 스케줄 성공 여부
    @discardableResult
    func scheduleTimeBasedNotification(_ item: NotificationItem) async throws -> Bool {
        // 알림 콘텐츠 생성
        let content = createContent(for: item)
        
        // 트리거 생성
        let trigger = createTimeTrigger(for: item)
        
        // 요청 생성 및 추가
        let request = UNNotificationRequest(
            identifier: item.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        try await center.add(request)
        return true
    }
    
    /// 위치 기반 알림 스케줄 (특정 위치 도착/출발 시)
    /// - Parameters:
    ///   - item: 알림 아이템
    ///   - coordinate: 목표 좌표
    ///   - radius: 반경 (미터)
    ///   - onEntry: 진입 시 알림 (false면 이탈 시)
    @discardableResult
    func scheduleLocationBasedNotification(
        _ item: NotificationItem,
        coordinate: CLLocationCoordinate2D,
        radius: CLLocationDistance = 100,
        onEntry: Bool = true
    ) async throws -> Bool {
        let content = createContent(for: item)
        
        // 위치 기반 트리거
        let region = CLCircularRegion(
            center: coordinate,
            radius: radius,
            identifier: item.id.uuidString
        )
        region.notifyOnEntry = onEntry
        region.notifyOnExit = !onEntry
        
        let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: item.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        try await center.add(request)
        return true
    }
    
    /// 즉시 알림 발송 (테스트용)
    func sendImmediateNotification(_ item: NotificationItem) async throws {
        let content = createContent(for: item)
        
        // 1초 후 발송
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: item.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        try await center.add(request)
    }
    
    // MARK: - 알림 관리
    
    /// 특정 알림 취소
    func cancelNotification(id: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }
    
    /// 여러 알림 취소
    func cancelNotifications(ids: [UUID]) {
        center.removePendingNotificationRequests(withIdentifiers: ids.map { $0.uuidString })
    }
    
    /// 모든 예약된 알림 취소
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
    
    /// 예약된 알림 목록 조회
    func getPendingNotifications() async -> [UNNotificationRequest] {
        await center.pendingNotificationRequests()
    }
    
    /// 전달된 알림 (알림 센터에 있는) 목록 조회
    func getDeliveredNotifications() async -> [UNNotification] {
        await center.deliveredNotifications()
    }
    
    /// 전달된 알림 제거
    func removeDeliveredNotification(id: UUID) {
        center.removeDeliveredNotifications(withIdentifiers: [id.uuidString])
    }
    
    /// 모든 전달된 알림 제거
    func removeAllDeliveredNotifications() {
        center.removeAllDeliveredNotifications()
    }
    
    // MARK: - 배지 관리
    
    /// 앱 배지 숫자 설정
    func setBadgeCount(_ count: Int) async throws {
        try await center.setBadgeCount(count)
    }
    
    /// 배지 초기화
    func clearBadge() async throws {
        try await center.setBadgeCount(0)
    }
    
    // MARK: - Private Helpers
    
    /// 알림 콘텐츠 생성
    private func createContent(for item: NotificationItem) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = item.title
        content.body = item.body
        content.categoryIdentifier = item.category.rawValue
        content.sound = .default
        content.badge = 1
        
        // 사용자 정보에 추가 데이터 저장
        content.userInfo = [
            "id": item.id.uuidString,
            "category": item.category.rawValue,
            "createdAt": Date().timeIntervalSince1970
        ]
        
        // 스레드 식별자 (그룹화)
        content.threadIdentifier = item.category.rawValue
        
        // 관련성 점수 (iOS 15+)
        content.relevanceScore = 0.8
        
        return content
    }
    
    /// 시간 기반 트리거 생성
    private func createTimeTrigger(for item: NotificationItem) -> UNCalendarNotificationTrigger {
        var dateComponents: DateComponents
        
        switch item.repeatInterval {
        case .none:
            // 특정 날짜/시간에 한 번
            dateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: item.scheduledDate
            )
            
        case .daily:
            // 매일 같은 시간
            dateComponents = Calendar.current.dateComponents(
                [.hour, .minute],
                from: item.scheduledDate
            )
            
        case .weekly:
            // 매주 같은 요일/시간
            dateComponents = Calendar.current.dateComponents(
                [.weekday, .hour, .minute],
                from: item.scheduledDate
            )
            
        case .monthly:
            // 매월 같은 날/시간
            dateComponents = Calendar.current.dateComponents(
                [.day, .hour, .minute],
                from: item.scheduledDate
            )
        }
        
        let repeats = item.repeatInterval != .none
        return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
    }
}

// MARK: - 알림 히스토리 관리

/// 발송된 알림 기록을 관리하는 저장소
@MainActor
class NotificationHistoryStore: ObservableObject {
    static let shared = NotificationHistoryStore()
    
    @Published var history: [NotificationHistoryItem] = []
    
    private let storageKey = "NotificationHistory"
    private let maxHistoryCount = 100
    
    private init() {
        loadHistory()
    }
    
    /// 히스토리에 추가
    func addToHistory(_ item: NotificationItem, deliveredAt: Date = Date()) {
        let historyItem = NotificationHistoryItem(
            id: UUID(),
            notificationId: item.id,
            title: item.title,
            body: item.body,
            category: item.category,
            deliveredAt: deliveredAt,
            wasOpened: false
        )
        
        history.insert(historyItem, at: 0)
        
        // 최대 개수 유지
        if history.count > maxHistoryCount {
            history = Array(history.prefix(maxHistoryCount))
        }
        
        saveHistory()
    }
    
    /// 열림 상태 업데이트
    func markAsOpened(id: UUID) {
        if let index = history.firstIndex(where: { $0.id == id }) {
            history[index].wasOpened = true
            saveHistory()
        }
    }
    
    /// 히스토리 삭제
    func removeFromHistory(id: UUID) {
        history.removeAll { $0.id == id }
        saveHistory()
    }
    
    /// 전체 히스토리 삭제
    func clearHistory() {
        history = []
        saveHistory()
    }
    
    private func saveHistory() {
        guard let data = try? JSONEncoder().encode(history) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
    
    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let items = try? JSONDecoder().decode([NotificationHistoryItem].self, from: data)
        else { return }
        history = items
    }
}

/// 알림 히스토리 아이템
struct NotificationHistoryItem: Identifiable, Codable {
    let id: UUID
    let notificationId: UUID
    let title: String
    let body: String
    let category: NotificationCategory
    let deliveredAt: Date
    var wasOpened: Bool
    
    /// 상대적 시간 표시
    var relativeTimeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: deliveredAt, relativeTo: Date())
    }
}
