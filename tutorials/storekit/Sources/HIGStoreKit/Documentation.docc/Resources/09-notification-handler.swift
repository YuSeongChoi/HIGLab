import Foundation

/// App Store Server Notification V2 핸들러
struct NotificationHandler {
    
    /// Notification V2 페이로드
    struct SignedPayload: Codable {
        let signedPayload: String
    }
    
    /// 디코딩된 알림
    struct DecodedNotification: Codable {
        let notificationType: NotificationType
        let subtype: NotificationSubtype?
        let data: NotificationData
        let notificationUUID: String
        let signedDate: Int
        
        enum NotificationType: String, Codable {
            case subscribed = "SUBSCRIBED"
            case didRenew = "DID_RENEW"
            case didFailToRenew = "DID_FAIL_TO_RENEW"
            case expired = "EXPIRED"
            case gracePeriodExpired = "GRACE_PERIOD_EXPIRED"
            case didChangeRenewalPref = "DID_CHANGE_RENEWAL_PREF"
            case didChangeRenewalStatus = "DID_CHANGE_RENEWAL_STATUS"
            case refund = "REFUND"
            case refundDeclined = "REFUND_DECLINED"
            case consumptionRequest = "CONSUMPTION_REQUEST"
            case renewalExtended = "RENEWAL_EXTENDED"
            case revoke = "REVOKE"
            case test = "TEST"
        }
        
        enum NotificationSubtype: String, Codable {
            case initialBuy = "INITIAL_BUY"
            case resubscribe = "RESUBSCRIBE"
            case upgrade = "UPGRADE"
            case downgrade = "DOWNGRADE"
            case autoRenewEnabled = "AUTO_RENEW_ENABLED"
            case autoRenewDisabled = "AUTO_RENEW_DISABLED"
            case voluntary = "VOLUNTARY"
            case billingRetry = "BILLING_RETRY"
            case priceIncrease = "PRICE_INCREASE"
            case gracePeriod = "GRACE_PERIOD"
            case billingRecovery = "BILLING_RECOVERY"
        }
    }
    
    struct NotificationData: Codable {
        let bundleId: String
        let environment: String
        let signedTransactionInfo: String
        let signedRenewalInfo: String?
    }
    
    /// JWS 페이로드에서 알림 디코딩
    func decode(signedPayload: String) throws -> DecodedNotification {
        let parts = signedPayload.split(separator: ".")
        guard parts.count == 3 else {
            throw NotificationError.invalidFormat
        }
        
        let payloadPart = String(parts[1])
        guard let payloadData = Data(base64URLEncoded: payloadPart) else {
            throw NotificationError.decodingFailed
        }
        
        return try JSONDecoder().decode(DecodedNotification.self, from: payloadData)
    }
    
    enum NotificationError: Error {
        case invalidFormat
        case decodingFailed
        case signatureInvalid
    }
}

extension Data {
    init?(base64URLEncoded string: String) {
        var base64 = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }
        
        self.init(base64Encoded: base64)
    }
}
