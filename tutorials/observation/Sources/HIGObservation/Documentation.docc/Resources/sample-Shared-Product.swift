import Foundation

// MARK: - 상품 모델
/// 쇼핑 앱에서 사용하는 기본 상품 데이터 모델

struct Product: Identifiable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let price: Int
    let category: ProductCategory
    let imageName: String
    let stockCount: Int
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        price: Int,
        category: ProductCategory,
        imageName: String,
        stockCount: Int = 100
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.category = category
        self.imageName = imageName
        self.stockCount = stockCount
    }
}

// MARK: - 상품 카테고리

enum ProductCategory: String, CaseIterable, Identifiable {
    case electronics = "전자기기"
    case clothing = "의류"
    case food = "식품"
    case books = "도서"
    case home = "홈/리빙"
    
    var id: String { rawValue }
    
    /// 카테고리별 SF Symbol
    var symbol: String {
        switch self {
        case .electronics: "desktopcomputer"
        case .clothing: "tshirt"
        case .food: "carrot"
        case .books: "book"
        case .home: "house"
        }
    }
}

// MARK: - 가격 포맷팅

extension Product {
    /// 원화 포맷팅된 가격 문자열
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: price)) ?? "\(price)"
        return "₩\(formatted)"
    }
}

// MARK: - Preview / Mock Data

extension Product {
    static let preview = Product(
        name: "AirPods Pro",
        description: "애플의 프리미엄 무선 이어폰. 액티브 노이즈 캔슬링과 공간 음향을 지원합니다.",
        price: 359000,
        category: .electronics,
        imageName: "airpodspro"
    )
    
    static let samples: [Product] = [
        // 전자기기
        Product(
            name: "AirPods Pro",
            description: "액티브 노이즈 캔슬링과 공간 음향을 지원하는 무선 이어폰",
            price: 359000,
            category: .electronics,
            imageName: "airpodspro"
        ),
        Product(
            name: "iPad Air",
            description: "M2 칩 탑재, 10.9인치 Liquid Retina 디스플레이",
            price: 899000,
            category: .electronics,
            imageName: "ipad"
        ),
        Product(
            name: "Apple Watch Series 9",
            description: "건강 모니터링과 피트니스 추적이 가능한 스마트워치",
            price: 599000,
            category: .electronics,
            imageName: "applewatch"
        ),
        
        // 의류
        Product(
            name: "캐시미어 니트",
            description: "부드러운 100% 캐시미어 소재의 프리미엄 니트",
            price: 189000,
            category: .clothing,
            imageName: "sweater"
        ),
        Product(
            name: "데님 재킷",
            description: "클래식한 디자인의 오버핏 데님 재킷",
            price: 129000,
            category: .clothing,
            imageName: "jacket"
        ),
        
        // 식품
        Product(
            name: "유기농 그래놀라",
            description: "건강한 아침을 위한 유기농 통곡물 그래놀라",
            price: 15000,
            category: .food,
            imageName: "granola"
        ),
        Product(
            name: "수제 잼 세트",
            description: "딸기, 블루베리, 살구 수제 잼 3종 세트",
            price: 28000,
            category: .food,
            imageName: "jam"
        ),
        
        // 도서
        Product(
            name: "SwiftUI 마스터북",
            description: "SwiftUI의 기초부터 고급 기법까지 완벽 가이드",
            price: 42000,
            category: .books,
            imageName: "book"
        ),
        
        // 홈/리빙
        Product(
            name: "아로마 디퓨저",
            description: "은은한 조명과 함께하는 초음파 아로마 디퓨저",
            price: 45000,
            category: .home,
            imageName: "diffuser"
        ),
        Product(
            name: "머그컵 세트",
            description: "북유럽 스타일 세라믹 머그컵 4개 세트",
            price: 32000,
            category: .home,
            imageName: "mug"
        ),
    ]
}
