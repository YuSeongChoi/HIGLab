import Foundation

/// 구독 이벤트 처리기
actor SubscriptionEventProcessor {
    
    private let database: SubscriptionDatabase
    private let notificationService: PushNotificationService
    
    init(database: SubscriptionDatabase, notificationService: PushNotificationService) {
        self.database = database
        self.notificationService = notificationService
    }
    
    /// 알림 타입에 따른 처리
    func process(_ notification: NotificationHandler.DecodedNotification) async {
        let userId = await database.getUserId(for: notification.data.bundleId)
        
        switch notification.notificationType {
        case .subscribed:
            await handleSubscribed(notification, userId: userId)
            
        case .didRenew:
            await handleRenewal(notification, userId: userId)
            
        case .didFailToRenew:
            await handleRenewalFailure(notification, userId: userId)
            
        case .expired:
            await handleExpired(notification, userId: userId)
            
        case .refund:
            await handleRefund(notification, userId: userId)
            
        case .didChangeRenewalPref:
            await handlePlanChange(notification, userId: userId)
            
        default:
            print("Unhandled notification: \(notification.notificationType)")
        }
    }
    
    // MARK: - Event Handlers
    
    private func handleSubscribed(
        _ notification: NotificationHandler.DecodedNotification,
        userId: String?
    ) async {
        guard let userId else { return }
        
        // 구독 상태 업데이트
        await database.updateSubscriptionStatus(
            userId: userId,
            status: .active,
            expirationDate: nil // 트랜잭션에서 추출
        )
        
        // 환영 이메일/푸시
        await notificationService.sendWelcome(to: userId)
    }
    
    private func handleRenewal(
        _ notification: NotificationHandler.DecodedNotification,
        userId: String?
    ) async {
        guard let userId else { return }
        
        await database.updateSubscriptionStatus(
            userId: userId,
            status: .active,
            expirationDate: nil
        )
    }
    
    private func handleRenewalFailure(
        _ notification: NotificationHandler.DecodedNotification,
        userId: String?
    ) async {
        guard let userId else { return }
        
        // 유예 기간 적용
        let gracePeriodEnd = Date().addingTimeInterval(7 * 24 * 60 * 60)
        
        await database.updateSubscriptionStatus(
            userId: userId,
            status: .gracePeriod,
            expirationDate: gracePeriodEnd
        )
        
        // 결제 업데이트 안내 푸시
        await notificationService.sendPaymentUpdateReminder(to: userId)
    }
    
    private func handleExpired(
        _ notification: NotificationHandler.DecodedNotification,
        userId: String?
    ) async {
        guard let userId else { return }
        
        await database.updateSubscriptionStatus(
            userId: userId,
            status: .expired,
            expirationDate: Date()
        )
        
        // 재구독 유도 메시지
        await notificationService.sendResubscribeReminder(to: userId)
    }
    
    private func handleRefund(
        _ notification: NotificationHandler.DecodedNotification,
        userId: String?
    ) async {
        guard let userId else { return }
        
        await database.updateSubscriptionStatus(
            userId: userId,
            status: .refunded,
            expirationDate: Date()
        )
    }
    
    private func handlePlanChange(
        _ notification: NotificationHandler.DecodedNotification,
        userId: String?
    ) async {
        guard let userId else { return }
        
        let isUpgrade = notification.subtype == .upgrade
        let message = isUpgrade ? "플랜이 업그레이드되었습니다!" : "다음 갱신 시 플랜이 변경됩니다."
        
        await notificationService.sendPlanChangeNotification(to: userId, message: message)
    }
}

// MARK: - Protocols (구현 필요)

protocol SubscriptionDatabase {
    func getUserId(for bundleId: String) async -> String?
    func updateSubscriptionStatus(userId: String, status: SubscriptionStatus, expirationDate: Date?) async
}

protocol PushNotificationService {
    func sendWelcome(to userId: String) async
    func sendPaymentUpdateReminder(to userId: String) async
    func sendResubscribeReminder(to userId: String) async
    func sendPlanChangeNotification(to userId: String, message: String) async
}

enum SubscriptionStatus {
    case active
    case gracePeriod
    case expired
    case refunded
}
