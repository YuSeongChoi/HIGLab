import SwiftUI

@main
struct DocumentScannerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("텍스트 인식") {
                    TextRecognitionView()
                }
                NavigationLink("얼굴 감지") {
                    FaceDetectionView()
                }
                NavigationLink("바코드 스캔") {
                    BarcodeScanView()
                }
                NavigationLink("문서 스캔") {
                    DocumentScanView()
                }
            }
            .navigationTitle("Document Scanner")
        }
    }
}
