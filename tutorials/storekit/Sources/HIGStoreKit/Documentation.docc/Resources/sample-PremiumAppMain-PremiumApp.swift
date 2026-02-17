import SwiftUI

// MARK: - PremiumApp
/// 앱의 메인 진입점
/// StoreKit 2를 활용한 인앱 구매 샘플 앱입니다.

@main
struct PremiumApp: App {
    // MARK: - 상태 관리
    
    /// StoreManager 인스턴스
    @State private var storeManager = StoreManager.shared
    
    // MARK: - 앱 구조
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(storeManager)
                .task {
                    // 앱 시작 시 상품 로드
                    await storeManager.loadProducts()
                }
        }
    }
}

// MARK: - 앱 정보
/// 앱 메타데이터

enum AppInfo {
    /// 앱 이름
    static let name = "PremiumApp"
    
    /// 앱 버전
    static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    
    /// 빌드 번호
    static let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    /// 전체 버전 문자열
    static var fullVersion: String {
        "\(version) (\(build))"
    }
}
