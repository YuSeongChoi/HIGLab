import ShazamKit

@available(iOS 17.0, *)
extension MusicRecognizer {
    /// 진행 중인 인식을 취소합니다
    func cancelRecognition() {
        session.cancel()
        state = .idle
        currentSong = nil
        errorMessage = nil
    }
}

// SwiftUI에서 사용 예시
/*
struct RecognitionView: View {
    @State private var recognizer = MusicRecognizer()
    
    var body: some View {
        Button(recognizer.isRecognizing ? "취소" : "인식") {
            if recognizer.isRecognizing {
                recognizer.cancelRecognition()
            } else {
                Task {
                    await recognizer.startRecognition()
                }
            }
        }
    }
}
*/
