// SharePlay 핵심 개념
// =====================

// SharePlay는 세 가지 핵심 특징을 가집니다:

// 1️⃣ 동기화된 재생
// - 모든 참가자가 같은 위치에서 미디어 재생
// - 한 명이 일시정지하면 모두 일시정지
// - 탐색(seek)도 모든 참가자에게 동기화

// 2️⃣ 실시간 소통
// - FaceTime 통화와 함께 사용
// - 또는 iMessage에서 SharePlay 시작
// - 영상 보면서 대화 가능

// 3️⃣ 시스템 통합
// - iOS, iPadOS, macOS, tvOS, visionOS 지원
// - Control Center, Dynamic Island 연동
// - PiP(Picture in Picture) 지원

import GroupActivities

// SharePlay 지원 앱의 기본 구조
@main
struct WatchTogetherApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    // SharePlay 세션 관찰 시작
                    for await session in WatchTogetherActivity.sessions() {
                        // 세션 처리
                    }
                }
        }
    }
}
