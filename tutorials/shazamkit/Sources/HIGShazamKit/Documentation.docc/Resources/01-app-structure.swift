import SwiftUI
import ShazamKit

@main
struct MusicRecognizerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var recognizer = MusicRecognizer()
    
    var body: some View {
        VStack(spacing: 20) {
            // 인식 상태 표시
            StatusView(state: recognizer.state)
            
            // 인식된 곡 정보
            if let song = recognizer.currentSong {
                SongView(song: song)
            }
            
            // 인식 버튼
            RecognizeButton(isRecognizing: recognizer.isRecognizing) {
                Task {
                    await recognizer.startRecognition()
                }
            }
        }
        .padding()
    }
}
