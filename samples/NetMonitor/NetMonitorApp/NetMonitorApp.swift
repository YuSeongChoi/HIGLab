import SwiftUI

/// NetMonitor - Network Framework 샘플 앱
/// 네트워크 상태 모니터링, TCP/UDP 연결, 에코 서버/클라이언트 기능 제공
@main
struct NetMonitorApp: App {
    /// 네트워크 모니터 (앱 전체에서 공유)
    @StateObject private var networkMonitor = NetworkMonitor()
    
    /// 연결 관리자 (앱 전체에서 공유)
    @StateObject private var connectionManager = ConnectionManager()
    
    /// 에코 서버 (앱 전체에서 공유)
    @StateObject private var echoServer = EchoServer()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(networkMonitor)
                .environmentObject(connectionManager)
                .environmentObject(echoServer)
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 900, height: 700)
        #endif
    }
}
