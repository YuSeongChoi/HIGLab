import Foundation

// MARK: - ProductService
/// Mock 상품 데이터 서비스
/// 실제 앱에서는 네트워크 레이어로 교체

actor ProductService {
    // MARK: - Singleton (선택적)
    
    static let shared = ProductService()
    
    // MARK: - 내부 저장소
    
    private var products: [Product] = Product.samples
    
    // MARK: - 상품 조회
    
    /// 모든 상품 목록 조회
    /// - Returns: 상품 배열
    func fetchAllProducts() async throws -> [Product] {
        // 네트워크 지연 시뮬레이션
        try await Task.sleep(for: .milliseconds(500))
        return products
    }
    
    /// 카테고리별 상품 조회
    /// - Parameter category: 상품 카테고리
    /// - Returns: 해당 카테고리의 상품 배열
    func fetchProducts(by category: ProductCategory) async throws -> [Product] {
        try await Task.sleep(for: .milliseconds(300))
        return products.filter { $0.category == category }
    }
    
    /// ID로 상품 조회
    /// - Parameter id: 상품 ID
    /// - Returns: 상품 (없으면 nil)
    func fetchProduct(id: UUID) async throws -> Product? {
        try await Task.sleep(for: .milliseconds(200))
        return products.first { $0.id == id }
    }
    
    /// 상품 검색
    /// - Parameter query: 검색어
    /// - Returns: 검색 결과 상품 배열
    func searchProducts(query: String) async throws -> [Product] {
        try await Task.sleep(for: .milliseconds(400))
        
        let lowercasedQuery = query.lowercased()
        return products.filter { product in
            product.name.lowercased().contains(lowercasedQuery) ||
            product.description.lowercased().contains(lowercasedQuery)
        }
    }
    
    // MARK: - 카테고리 정보
    
    /// 카테고리별 상품 개수
    /// - Returns: [카테고리: 상품 수] 딕셔너리
    func productCountByCategory() async -> [ProductCategory: Int] {
        var counts: [ProductCategory: Int] = [:]
        for category in ProductCategory.allCases {
            counts[category] = products.filter { $0.category == category }.count
        }
        return counts
    }
}

// MARK: - 에러 타입

enum ProductServiceError: LocalizedError {
    case notFound
    case networkError
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "상품을 찾을 수 없습니다."
        case .networkError:
            return "네트워크 오류가 발생했습니다."
        case .invalidResponse:
            return "잘못된 응답입니다."
        }
    }
}
