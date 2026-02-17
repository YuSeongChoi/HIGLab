import SwiftUI

// MARK: - MLClassifier 앱
// CoreML을 사용한 이미지 분류 데모 앱

@main
struct MLClassifierApp: App {
    
    // MARK: - 상태 객체
    @StateObject private var classifier = ImageClassifier()
    
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(classifier)
        }
    }
}
