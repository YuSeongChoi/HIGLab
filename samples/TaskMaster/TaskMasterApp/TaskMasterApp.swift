import SwiftUI
import SwiftData

// MARK: - 앱 진입점

/// TaskMaster 앱의 메인 엔트리 포인트
/// - SwiftData ModelContainer 설정
/// - 기본 카테고리 초기화
@main
struct TaskMasterApp: App {
    
    /// SwiftData 모델 컨테이너
    /// - TaskItem, Category 모델을 포함
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TaskItem.self,
            Category.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false  // 영구 저장
        )
        
        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            // 치명적 오류 - 앱 실행 불가
            fatalError("ModelContainer 생성 실패: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // 첫 실행 시 기본 카테고리 초기화
                    initializeDefaultData()
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    /// 기본 데이터 초기화
    @MainActor
    private func initializeDefaultData() {
        let context = sharedModelContainer.mainContext
        DataService.shared.initializeDefaultCategories(in: context)
    }
}

// MARK: - 프리뷰용 컨테이너

/// SwiftUI 프리뷰를 위한 인메모리 ModelContainer
extension ModelContainer {
    @MainActor
    static var preview: ModelContainer {
        let schema = Schema([TaskItem.self, Category.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true  // 메모리에만 저장 (프리뷰용)
        )
        
        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
            
            // 샘플 데이터 추가
            DataService.shared.createSampleData(in: container.mainContext)
            
            return container
        } catch {
            fatalError("Preview ModelContainer 생성 실패: \(error)")
        }
    }
}
