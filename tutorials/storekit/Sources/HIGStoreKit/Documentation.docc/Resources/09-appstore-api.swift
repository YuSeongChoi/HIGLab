import Foundation

/// App Store Server API 클라이언트
actor AppStoreServerAPI {
    
    private let jwtGenerator: AppStoreJWT
    private let environment: Environment
    
    enum Environment {
        case sandbox
        case production
        
        var baseURL: String {
            switch self {
            case .sandbox:
                return "https://api.storekit-sandbox.itunes.apple.com"
            case .production:
                return "https://api.storekit.itunes.apple.com"
            }
        }
    }
    
    init(jwtGenerator: AppStoreJWT, environment: Environment = .production) {
        self.jwtGenerator = jwtGenerator
        self.environment = environment
    }
    
    /// 구독 상태 조회
    func getAllSubscriptionStatuses(
        transactionId: String
    ) async throws -> SubscriptionStatusResponse {
        let url = URL(string: "\(environment.baseURL)/inApps/v1/subscriptions/\(transactionId)")!
        let token = try jwtGenerator.generateToken()
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode(SubscriptionStatusResponse.self, from: data)
    }
    
    /// 트랜잭션 히스토리 조회
    func getTransactionHistory(
        transactionId: String,
        revision: String? = nil
    ) async throws -> TransactionHistoryResponse {
        var urlComponents = URLComponents(
            string: "\(environment.baseURL)/inApps/v1/history/\(transactionId)"
        )!
        
        if let revision = revision {
            urlComponents.queryItems = [URLQueryItem(name: "revision", value: revision)]
        }
        
        let token = try jwtGenerator.generateToken()
        var request = URLRequest(url: urlComponents.url!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(TransactionHistoryResponse.self, from: data)
    }
    
    // MARK: - Response Types
    
    struct SubscriptionStatusResponse: Codable {
        let environment: String
        let bundleId: String
        let data: [SubscriptionGroupStatus]
    }
    
    struct SubscriptionGroupStatus: Codable {
        let subscriptionGroupIdentifier: String
        let lastTransactions: [LastTransaction]
    }
    
    struct LastTransaction: Codable {
        let status: Int
        let signedTransactionInfo: String
        let signedRenewalInfo: String
    }
    
    struct TransactionHistoryResponse: Codable {
        let revision: String
        let hasMore: Bool
        let signedTransactions: [String]
    }
    
    enum APIError: Error {
        case invalidResponse
        case unauthorized
    }
}
