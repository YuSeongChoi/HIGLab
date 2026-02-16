import SwiftUI
import SwiftData

// 가장 간단한 ModelContainer 설정
// 단 한 줄로 SwiftData 연결 완료!

@main
struct TaskMasterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // ✨ 이 한 줄이 전부!
        .modelContainer(for: TaskItem.self)
    }
}

// ─────────────────────────────────────────

// 이 한 줄이 하는 일:
// 1. TaskItem 스키마 등록
// 2. SQLite 파일 생성 (앱 샌드박스 내)
// 3. ModelContainer 인스턴스 생성
// 4. mainContext 생성
// 5. 모든 하위 뷰에 Environment로 주입

// 저장 위치 (시뮬레이터):
// ~/Library/Developer/CoreSimulator/Devices/[ID]/data/Containers/Data/Application/[ID]/Library/Application Support/

// 파일명:
// default.store (SQLite)
// default.store-shm
// default.store-wal
