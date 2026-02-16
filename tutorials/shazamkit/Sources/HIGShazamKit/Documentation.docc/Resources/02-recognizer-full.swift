import SwiftUI
import ShazamKit
import AVFoundation
import Observation

@available(iOS 17.0, *)
@Observable
final class MusicRecognizer {
    // MARK: - Properties
    private let session = SHManagedSession()
    
    var state: RecognitionState = .idle
    var currentSong: Song?
    var errorMessage: String?
    
    var isRecognizing: Bool {
        state == .listening || state == .matching
    }
    
    // MARK: - Initialization
    init() {
        observeSessionState()
    }
    
    // MARK: - Recognition
    @MainActor
    func startRecognition() async {
        guard await checkMicrophonePermission() else {
            state = .error("마이크 권한이 필요합니다")
            return
        }
        
        state = .listening
        currentSong = nil
        errorMessage = nil
        
        let result = await session.result()
        handleResult(result)
    }
    
    func cancelRecognition() {
        session.cancel()
        state = .idle
    }
    
    // MARK: - Private Methods
    private func handleResult(_ result: SHSession.Result) {
        switch result {
        case .match(let match):
            if let item = match.mediaItems.first {
                currentSong = Song(from: item)
                state = .matched
            }
        case .noMatch:
            state = .noMatch
        case .error(let error, _):
            state = .error(error.localizedDescription)
            errorMessage = error.localizedDescription
        }
    }
    
    private func checkMicrophonePermission() async -> Bool {
        let status = AVAudioApplication.shared.recordPermission
        if status == .granted { return true }
        if status == .undetermined {
            return await AVAudioApplication.requestRecordPermission()
        }
        return false
    }
    
    private func observeSessionState() {
        Task {
            for await sessionState in session.state {
                await MainActor.run {
                    switch sessionState {
                    case .prerecording: state = .listening
                    case .matching: state = .matching
                    default: break
                    }
                }
            }
        }
    }
}
