import SwiftUI
import SwiftData

// ModelConfiguration으로 세밀한 설정

@main
struct TaskMasterApp: App {
    var container: ModelContainer
    
    init() {
        // 스키마 정의
        let schema = Schema([
            TaskItem.self,
            Category.self
        ])
        
        // 설정 옵션들
        let config = ModelConfiguration(
            // 스키마
            schema: schema,
            
            // 저장 위치 (nil이면 기본 위치)
            url: nil,
            
            // true면 메모리에만 저장 (테스트용)
            isStoredInMemoryOnly: false,
            
            // false면 읽기 전용
            allowsSave: true,
            
            // App Group 공유 설정
            groupContainer: .automatic,
            
            // CloudKit 컨테이너 (nil이면 로컬만)
            cloudKitDatabase: .none
        )
        
        do {
            container = try ModelContainer(
                for: schema,
                configurations: [config]
            )
        } catch {
            fatalError("ModelContainer 초기화 실패: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}

// ─────────────────────────────────────────

// 다양한 설정 예시

// 1. 메모리 전용 (테스트/Preview)
let testConfig = ModelConfiguration(isStoredInMemoryOnly: true)

// 2. 커스텀 저장 위치
let customURL = URL.documentsDirectory.appending(path: "MyData.store")
let customConfig = ModelConfiguration(url: customURL)

// 3. 읽기 전용 (번들 데이터)
let bundleURL = Bundle.main.url(forResource: "SeedData", withExtension: "store")!
let readOnlyConfig = ModelConfiguration(url: bundleURL, allowsSave: false)

// 4. App Group 공유 (위젯, App Extension)
let sharedConfig = ModelConfiguration(
    groupContainer: .identifier("group.com.example.taskmaster")
)
