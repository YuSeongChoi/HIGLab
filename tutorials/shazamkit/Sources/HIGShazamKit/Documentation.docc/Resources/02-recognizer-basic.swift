import SwiftUI
import ShazamKit
import Observation

@available(iOS 17.0, *)
@Observable
class MusicRecognizer {
    // 인식 세션
    private let session = SHManagedSession()
    
    // 현재 인식 상태
    var state: RecognitionState = .idle
    
    // 인식된 곡 정보
    var currentSong: Song?
    
    // 에러 메시지
    var errorMessage: String?
    
    // 인식 중인지 여부
    var isRecognizing: Bool {
        state == .listening || state == .matching
    }
}
