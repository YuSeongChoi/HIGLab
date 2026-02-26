import Foundation

struct Product: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let price: Decimal
    let imageName: String
    let category: Category
    
    enum Category: String, CaseIterable {
        case electronics = "전자기기"
        case clothing = "의류"
        case food = "식품"
        case accessories = "액세서리"
    }
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: price as NSDecimalNumber) ?? "₩0"
    }
}

// MARK: - Sample Data
extension Product {
    static let samples: [Product] = [
        Product(id: "1", name: "AirPods Pro", description: "노이즈 캔슬링 이어폰", price: 359000, imageName: "airpodspro", category: .electronics),
        Product(id: "2", name: "MacBook Air", description: "M3 칩 탑재 노트북", price: 1590000, imageName: "laptopcomputer", category: .electronics),
        Product(id: "3", name: "프리미엄 후드티", description: "편안한 착용감", price: 89000, imageName: "tshirt", category: .clothing),
        Product(id: "4", name: "가죽 지갑", description: "천연 소가죽", price: 120000, imageName: "wallet.pass", category: .accessories),
        Product(id: "5", name: "유기농 커피", description: "콜롬비아산 원두", price: 25000, imageName: "cup.and.saucer", category: .food),
        Product(id: "6", name: "Apple Watch", description: "Series 9 GPS", price: 599000, imageName: "applewatch", category: .electronics),
        Product(id: "7", name: "캔버스 토트백", description: "넉넉한 수납공간", price: 45000, imageName: "bag", category: .accessories),
        Product(id: "8", name: "오가닉 그래놀라", description: "건강한 아침식사", price: 18000, imageName: "leaf", category: .food),
    ]
}
