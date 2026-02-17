import SwiftUI
import GroupActivities

// MARK: - WatchParty 앱 메인 엔트리포인트
// SharePlay를 활용한 동영상 함께 보기 앱

@main
struct WatchPartyApp: App {
    /// SharePlay 매니저 (앱 전체에서 공유)
    @StateObject private var sharePlayManager = SharePlayManager()
    
    /// 그룹 상태 감시자
    @StateObject private var groupStateObserver = GroupStateObserver()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sharePlayManager)
                .environmentObject(groupStateObserver)
                .task {
                    // 앱 시작 시 GroupActivity 세션 감시 시작
                    await configureGroupActivities()
                }
        }
    }
    
    /// GroupActivity 설정 및 감시 시작
    private func configureGroupActivities() async {
        // WatchPartyActivity 세션 감시
        for await session in WatchPartyActivity.sessions() {
            // 새 세션 시작 시 SharePlay 매니저에 전달
            await sharePlayManager.configureSession(session)
        }
    }
}

// MARK: - 앱 상수
/// 앱 전체에서 사용하는 상수값들
enum AppConstants {
    /// 앱 이름
    static let appName = "WatchParty"
    
    /// 앱 버전
    static let version = "1.0.0"
    
    /// 최대 참여자 수
    static let maxParticipants = 32
    
    /// 동기화 간격 (초)
    static let syncInterval: TimeInterval = 1.0
    
    /// 하트비트 간격 (초)
    static let heartbeatInterval: TimeInterval = 5.0
    
    /// 동기화 허용 오차 (초)
    static let syncTolerance: TimeInterval = 0.5
    
    /// 반응 표시 시간 (초)
    static let reactionDisplayDuration: TimeInterval = 3.0
}

// MARK: - 앱 테마
/// 앱 UI 테마 정의
enum AppTheme {
    /// 주요 색상
    static let primaryColor = Color.purple
    
    /// 보조 색상
    static let secondaryColor = Color.pink
    
    /// 배경 색상
    static let backgroundColor = Color(.systemBackground)
    
    /// 카드 배경 색상
    static let cardBackgroundColor = Color(.secondarySystemBackground)
    
    /// 그라데이션
    static let gradient = LinearGradient(
        colors: [primaryColor, secondaryColor],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// 모서리 반경
    static let cornerRadius: CGFloat = 12
    
    /// 기본 패딩
    static let defaultPadding: CGFloat = 16
    
    /// 아이콘 크기
    static let iconSize: CGFloat = 24
    
    /// 썸네일 크기
    static let thumbnailSize = CGSize(width: 160, height: 90)
}

// MARK: - Preview Provider
#Preview {
    ContentView()
        .environmentObject(SharePlayManager())
        .environmentObject(GroupStateObserver())
}
