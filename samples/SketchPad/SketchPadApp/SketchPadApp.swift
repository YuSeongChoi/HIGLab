import SwiftUI

// MARK: - SketchPadApp
// PencilKit 기반 드로잉 앱의 진입점

@main
struct SketchPadApp: App {
    // MARK: - 상태
    
    /// 드로잉 저장소 (앱 전체에서 공유)
    @State private var drawingStore = DrawingStore()
    
    /// 도구 팔레트 (앱 전체에서 공유)
    @State private var toolPalette = ToolPalette()
    
    // MARK: - 본문
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(drawingStore)
                .environment(toolPalette)
        }
    }
}
