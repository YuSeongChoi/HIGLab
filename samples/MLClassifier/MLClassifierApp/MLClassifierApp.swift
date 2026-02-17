import SwiftUI

// MARK: - MLClassifier 앱
// CoreML을 사용한 이미지 분류 데모 앱
// MLModel, VNCoreMLRequest, MLModelConfiguration 등 Core ML API 종합 활용

@main
struct MLClassifierApp: App {
    
    // MARK: - 상태 객체
    /// 이미지 분류기
    @StateObject private var classifier = ImageClassifier()
    
    /// 객체 탐지기
    @StateObject private var detector = ObjectDetector()
    
    /// Vision 분석기 (텍스트/얼굴/포즈)
    @StateObject private var analyzer = VisionAnalyzer()
    
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(classifier)
                .environmentObject(detector)
                .environmentObject(analyzer)
        }
    }
}
