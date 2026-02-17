import Foundation
import PassKit

// MARK: - 배송 방법
/// Apple Pay 결제에서 사용하는 배송 옵션 모델
///
/// ## PKShippingMethod 연동
/// Apple Pay 결제 시트에서 배송 옵션을 표시하기 위해
/// `PKShippingMethod`로 변환하여 사용합니다.
///
/// ## 사용 예시
/// ```swift
/// let express = ShippingMethod.express
/// let pkMethod = express.toPKShippingMethod()
/// ```

struct ShippingMethod: Identifiable, Hashable, Sendable {
    
    // MARK: - 속성
    
    /// 고유 식별자
    let id: String
    
    /// 배송 방법 이름 (예: "일반 배송")
    let name: String
    
    /// 상세 설명 (예: "3-5 영업일 소요")
    let detail: String
    
    /// 배송비 (원화)
    let price: Int
    
    /// 배송 타입
    let type: ShippingType
    
    /// 예상 배송 기간 (영업일 기준)
    let estimatedDeliveryDays: ClosedRange<Int>
    
    /// 무료 배송 최소 금액 (nil이면 무료 배송 미적용)
    let freeShippingThreshold: Int?
    
    /// 지원 지역 (nil이면 전국)
    let supportedRegions: [String]?
    
    /// 활성화 여부
    let isAvailable: Bool
    
    // MARK: - 초기화
    
    init(
        id: String = UUID().uuidString,
        name: String,
        detail: String,
        price: Int,
        type: ShippingType = .standard,
        estimatedDeliveryDays: ClosedRange<Int>,
        freeShippingThreshold: Int? = nil,
        supportedRegions: [String]? = nil,
        isAvailable: Bool = true
    ) {
        self.id = id
        self.name = name
        self.detail = detail
        self.price = price
        self.type = type
        self.estimatedDeliveryDays = estimatedDeliveryDays
        self.freeShippingThreshold = freeShippingThreshold
        self.supportedRegions = supportedRegions
        self.isAvailable = isAvailable
    }
    
    // MARK: - 배송 타입
    
    enum ShippingType: String, CaseIterable, Sendable {
        /// 일반 배송 (3-5일)
        case standard = "standard"
        /// 빠른 배송 (1-2일)
        case express = "express"
        /// 당일 배송
        case sameDay = "sameDay"
        /// 새벽 배송
        case dawn = "dawn"
        /// 방문 수령
        case pickup = "pickup"
        /// 편의점 수령
        case convenienceStore = "convenienceStore"
        
        /// 표시 이름
        var displayName: String {
            switch self {
            case .standard: return "일반 배송"
            case .express: return "빠른 배송"
            case .sameDay: return "당일 배송"
            case .dawn: return "새벽 배송"
            case .pickup: return "방문 수령"
            case .convenienceStore: return "편의점 수령"
            }
        }
        
        /// SF Symbol 아이콘
        var symbol: String {
            switch self {
            case .standard: return "shippingbox"
            case .express: return "hare"
            case .sameDay: return "clock.badge.checkmark"
            case .dawn: return "sunrise"
            case .pickup: return "storefront"
            case .convenienceStore: return "building.2"
            }
        }
        
        /// PKShippingType 변환
        var pkShippingType: PKShippingType {
            switch self {
            case .standard, .express, .dawn:
                return .shipping
            case .sameDay:
                return .shipping
            case .pickup, .convenienceStore:
                return .storePickup
            }
        }
    }
}

// MARK: - 가격 계산

extension ShippingMethod {
    
    /// 주문 금액에 따른 실제 배송비 계산
    /// - Parameter orderAmount: 주문 총액
    /// - Returns: 실제 적용될 배송비
    func calculatePrice(for orderAmount: Int) -> Int {
        // 무료 배송 조건 확인
        if let threshold = freeShippingThreshold, orderAmount >= threshold {
            return 0
        }
        return price
    }
    
    /// 무료 배송까지 남은 금액
    /// - Parameter orderAmount: 현재 주문 총액
    /// - Returns: 무료 배송까지 필요한 추가 금액 (이미 무료면 nil)
    func remainingForFreeShipping(orderAmount: Int) -> Int? {
        guard let threshold = freeShippingThreshold else { return nil }
        let remaining = threshold - orderAmount
        return remaining > 0 ? remaining : nil
    }
    
    /// 포맷팅된 배송비
    var formattedPrice: String {
        if price == 0 {
            return "무료"
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: price)) ?? "\(price)"
        return "₩\(formatted)"
    }
    
    /// 주문 금액 기준 포맷팅된 배송비
    func formattedPrice(for orderAmount: Int) -> String {
        let actualPrice = calculatePrice(for: orderAmount)
        if actualPrice == 0 {
            return "무료"
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: actualPrice)) ?? "\(actualPrice)"
        return "₩\(formatted)"
    }
}

// MARK: - 배송 기간

extension ShippingMethod {
    
    /// 예상 배송일 범위 문자열
    var estimatedDeliveryDescription: String {
        let min = estimatedDeliveryDays.lowerBound
        let max = estimatedDeliveryDays.upperBound
        
        if min == max {
            if min == 0 {
                return "오늘 도착"
            } else if min == 1 {
                return "내일 도착"
            }
            return "\(min)일 후 도착"
        }
        return "\(min)-\(max) 영업일"
    }
    
    /// 예상 배송일 계산
    /// - Parameter from: 기준일 (기본값: 오늘)
    /// - Returns: 예상 배송일 범위
    func estimatedDeliveryDate(from date: Date = Date()) -> (earliest: Date, latest: Date) {
        let calendar = Calendar.current
        let earliest = calendar.date(
            byAdding: .day,
            value: estimatedDeliveryDays.lowerBound,
            to: date
        ) ?? date
        let latest = calendar.date(
            byAdding: .day,
            value: estimatedDeliveryDays.upperBound,
            to: date
        ) ?? date
        return (earliest, latest)
    }
    
    /// 포맷팅된 예상 배송일
    func formattedDeliveryDate(from date: Date = Date()) -> String {
        let (earliest, latest) = estimatedDeliveryDate(from: date)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E)"
        
        if earliest == latest {
            return formatter.string(from: earliest)
        }
        
        let shortFormatter = DateFormatter()
        shortFormatter.locale = Locale(identifier: "ko_KR")
        shortFormatter.dateFormat = "M/d"
        
        return "\(shortFormatter.string(from: earliest)) ~ \(formatter.string(from: latest))"
    }
}

// MARK: - PKShippingMethod 변환

extension ShippingMethod {
    
    /// PKShippingMethod로 변환
    /// - Parameter orderAmount: 주문 금액 (무료 배송 계산용)
    /// - Returns: Apple Pay 배송 옵션
    func toPKShippingMethod(for orderAmount: Int = 0) -> PKShippingMethod {
        let method = PKShippingMethod(
            label: name,
            amount: NSDecimalNumber(value: calculatePrice(for: orderAmount))
        )
        method.identifier = id
        method.detail = detail
        
        // iOS 15+: 예상 배송일 표시
        let (earliest, latest) = estimatedDeliveryDate()
        method.dateComponentsRange = PKDateComponentsRange(
            start: Calendar.current.dateComponents([.year, .month, .day], from: earliest),
            end: Calendar.current.dateComponents([.year, .month, .day], from: latest)
        )
        
        return method
    }
    
    /// PKShippingMethod 배열로 변환
    /// - Parameters:
    ///   - methods: 변환할 배송 방법 배열
    ///   - orderAmount: 주문 금액
    /// - Returns: PKShippingMethod 배열
    static func toPKShippingMethods(
        _ methods: [ShippingMethod],
        for orderAmount: Int = 0
    ) -> [PKShippingMethod] {
        methods
            .filter { $0.isAvailable }
            .map { $0.toPKShippingMethod(for: orderAmount) }
    }
}

// MARK: - 지역 지원 확인

extension ShippingMethod {
    
    /// 특정 주소에서 사용 가능한지 확인
    /// - Parameter postalCode: 우편번호
    /// - Returns: 사용 가능 여부
    func isAvailable(for postalCode: String) -> Bool {
        guard isAvailable else { return false }
        guard let regions = supportedRegions else { return true }
        
        // 우편번호 앞 2자리로 지역 확인 (한국 기준)
        let prefix = String(postalCode.prefix(2))
        return regions.contains(prefix)
    }
    
    /// 특정 지역에서 사용 가능한 배송 방법 필터링
    /// - Parameters:
    ///   - methods: 배송 방법 배열
    ///   - postalCode: 우편번호
    /// - Returns: 사용 가능한 배송 방법 배열
    static func availableMethods(
        from methods: [ShippingMethod],
        for postalCode: String
    ) -> [ShippingMethod] {
        methods.filter { $0.isAvailable(for: postalCode) }
    }
}

// MARK: - 미리 정의된 배송 옵션

extension ShippingMethod {
    
    /// 일반 배송 (무료, 3-5일)
    static let standard = ShippingMethod(
        id: "standard",
        name: "일반 배송",
        detail: "3-5 영업일 소요",
        price: 0,
        type: .standard,
        estimatedDeliveryDays: 3...5,
        freeShippingThreshold: nil
    )
    
    /// 일반 배송 (유료)
    static let standardPaid = ShippingMethod(
        id: "standard_paid",
        name: "일반 배송",
        detail: "3-5 영업일 소요 · 5만원 이상 무료",
        price: 3000,
        type: .standard,
        estimatedDeliveryDays: 3...5,
        freeShippingThreshold: 50000
    )
    
    /// 빠른 배송
    static let express = ShippingMethod(
        id: "express",
        name: "빠른 배송",
        detail: "1-2 영업일 소요",
        price: 5000,
        type: .express,
        estimatedDeliveryDays: 1...2
    )
    
    /// 당일 배송 (수도권)
    static let sameDay = ShippingMethod(
        id: "same_day",
        name: "당일 배송",
        detail: "오후 2시 이전 주문 시 당일 도착",
        price: 8000,
        type: .sameDay,
        estimatedDeliveryDays: 0...0,
        supportedRegions: ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18"]
    )
    
    /// 새벽 배송 (수도권)
    static let dawn = ShippingMethod(
        id: "dawn",
        name: "새벽 배송",
        detail: "밤 12시 이전 주문 시 새벽 7시 전 도착",
        price: 4000,
        type: .dawn,
        estimatedDeliveryDays: 1...1,
        supportedRegions: ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15"]
    )
    
    /// 매장 수령
    static let storePickup = ShippingMethod(
        id: "pickup",
        name: "매장 방문 수령",
        detail: "가까운 매장에서 직접 수령",
        price: 0,
        type: .pickup,
        estimatedDeliveryDays: 1...2
    )
    
    /// 편의점 수령
    static let convenienceStore = ShippingMethod(
        id: "cvs_pickup",
        name: "편의점 수령",
        detail: "CU, GS25, 세븐일레븐에서 수령",
        price: 2000,
        type: .convenienceStore,
        estimatedDeliveryDays: 2...3
    )
    
    /// 기본 배송 옵션 세트
    static let defaultMethods: [ShippingMethod] = [
        .standardPaid,
        .express,
        .sameDay,
        .dawn
    ]
    
    /// 전체 배송 옵션 세트
    static let allMethods: [ShippingMethod] = [
        .standardPaid,
        .express,
        .sameDay,
        .dawn,
        .storePickup,
        .convenienceStore
    ]
}

// MARK: - Codable

extension ShippingMethod: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, detail, price, type
        case estimatedDeliveryDaysMin = "estimated_delivery_days_min"
        case estimatedDeliveryDaysMax = "estimated_delivery_days_max"
        case freeShippingThreshold = "free_shipping_threshold"
        case supportedRegions = "supported_regions"
        case isAvailable = "is_available"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        detail = try container.decode(String.self, forKey: .detail)
        price = try container.decode(Int.self, forKey: .price)
        type = try container.decode(ShippingType.self, forKey: .type)
        let min = try container.decode(Int.self, forKey: .estimatedDeliveryDaysMin)
        let max = try container.decode(Int.self, forKey: .estimatedDeliveryDaysMax)
        estimatedDeliveryDays = min...max
        freeShippingThreshold = try container.decodeIfPresent(Int.self, forKey: .freeShippingThreshold)
        supportedRegions = try container.decodeIfPresent([String].self, forKey: .supportedRegions)
        isAvailable = try container.decodeIfPresent(Bool.self, forKey: .isAvailable) ?? true
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(detail, forKey: .detail)
        try container.encode(price, forKey: .price)
        try container.encode(type, forKey: .type)
        try container.encode(estimatedDeliveryDays.lowerBound, forKey: .estimatedDeliveryDaysMin)
        try container.encode(estimatedDeliveryDays.upperBound, forKey: .estimatedDeliveryDaysMax)
        try container.encodeIfPresent(freeShippingThreshold, forKey: .freeShippingThreshold)
        try container.encodeIfPresent(supportedRegions, forKey: .supportedRegions)
        try container.encode(isAvailable, forKey: .isAvailable)
    }
}

extension ShippingMethod.ShippingType: Codable {}

// MARK: - CustomDebugStringConvertible

extension ShippingMethod: CustomDebugStringConvertible {
    var debugDescription: String {
        """
        ShippingMethod(
            id: \(id),
            name: \(name),
            price: \(formattedPrice),
            type: \(type.displayName),
            delivery: \(estimatedDeliveryDescription)
        )
        """
    }
}
