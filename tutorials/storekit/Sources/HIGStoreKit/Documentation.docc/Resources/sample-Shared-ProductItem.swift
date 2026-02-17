import StoreKit

// MARK: - ProductItem
/// StoreKit Product를 래핑하는 구조체
/// 앱 내에서 사용하기 쉬운 형태로 상품 정보를 제공합니다.

struct ProductItem: Identifiable, Hashable {
    // MARK: - 속성
    
    /// 상품 고유 식별자
    let id: String
    
    /// StoreKit Product 원본
    let product: Product
    
    /// 상품 유형 (소모성, 비소모성, 구독 등)
    var type: Product.ProductType {
        product.type
    }
    
    /// 표시용 이름
    var displayName: String {
        product.displayName
    }
    
    /// 상품 설명
    var description: String {
        product.description
    }
    
    /// 현지화된 가격 문자열
    var displayPrice: String {
        product.displayPrice
    }
    
    /// 가격 (Decimal)
    var price: Decimal {
        product.price
    }
    
    // MARK: - 초기화
    
    init(product: Product) {
        self.id = product.id
        self.product = product
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ProductItem, rhs: ProductItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 상품 ID 상수
/// 앱에서 사용하는 상품 ID를 정의합니다.
/// App Store Connect에 등록된 ID와 일치해야 합니다.

extension ProductItem {
    /// 상품 ID 목록
    enum ProductID {
        // MARK: 비소모성 상품 (한 번 구매, 영구 소유)
        static let premiumUnlock = "com.higlab.premiumapp.premium_unlock"
        static let proFeatures = "com.higlab.premiumapp.pro_features"
        
        // MARK: 소모성 상품 (여러 번 구매 가능)
        static let coins100 = "com.higlab.premiumapp.coins_100"
        static let coins500 = "com.higlab.premiumapp.coins_500"
        
        // MARK: 자동 갱신 구독
        static let monthlySubscription = "com.higlab.premiumapp.subscription_monthly"
        static let yearlySubscription = "com.higlab.premiumapp.subscription_yearly"
        
        /// 모든 상품 ID 배열
        static let all: [String] = [
            premiumUnlock,
            proFeatures,
            coins100,
            coins500,
            monthlySubscription,
            yearlySubscription
        ]
    }
}

// MARK: - 상품 유형 확장
extension ProductItem {
    /// 구독 상품인지 확인
    var isSubscription: Bool {
        type == .autoRenewable || type == .nonRenewable
    }
    
    /// 소모성 상품인지 확인
    var isConsumable: Bool {
        type == .consumable
    }
    
    /// 비소모성 상품인지 확인
    var isNonConsumable: Bool {
        type == .nonConsumable
    }
    
    /// 상품 유형 한글 설명
    var typeDescription: String {
        switch type {
        case .consumable:
            return "소모성"
        case .nonConsumable:
            return "비소모성"
        case .autoRenewable:
            return "자동 갱신 구독"
        case .nonRenewable:
            return "비갱신 구독"
        @unknown default:
            return "알 수 없음"
        }
    }
}
