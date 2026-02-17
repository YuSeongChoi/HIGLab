import Foundation
import ShazamKit
import AVFAudio

// MARK: - ShazamManager
// SHManagedSession을 사용한 음악 인식 관리자

@MainActor
@Observable
final class ShazamManager {
    // MARK: - 상태
    enum State: Equatable {
        case idle           // 대기 중
        case listening      // 듣는 중
        case matched        // 매칭 성공
        case noMatch        // 매칭 실패
        case error(String)  // 오류 발생
        
        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.listening, .listening),
                 (.matched, .matched), (.noMatch, .noMatch):
                return true
            case (.error(let l), .error(let r)):
                return l == r
            default:
                return false
            }
        }
    }
    
    // MARK: - 프로퍼티
    private(set) var state: State = .idle
    private(set) var matchedSong: MatchedSong?
    
    private var session: SHManagedSession?
    private let history: MatchHistory
    
    // MARK: - 초기화
    init(history: MatchHistory = .shared) {
        self.history = history
    }
    
    // MARK: - 인식 시작
    func startListening() async {
        // 마이크 권한 확인
        guard await requestMicrophonePermission() else {
            state = .error("마이크 권한이 필요합니다")
            return
        }
        
        // 세션 생성
        session = SHManagedSession()
        state = .listening
        matchedSong = nil
        
        // 결과 스트림 처리
        guard let session = session else { return }
        
        for await result in session.results {
            switch result {
            case .match(let match):
                // 첫 번째 미디어 아이템 사용
                if let mediaItem = match.mediaItems.first {
                    let song = MatchedSong(from: mediaItem)
                    matchedSong = song
                    history.add(song)
                    state = .matched
                }
                stopListening()
                return
                
            case .noMatch:
                state = .noMatch
                stopListening()
                return
                
            case .error(let error):
                state = .error(error.localizedDescription)
                stopListening()
                return
                
            @unknown default:
                break
            }
        }
    }
    
    // MARK: - 인식 중지
    func stopListening() {
        session?.cancel()
        session = nil
        if state == .listening {
            state = .idle
        }
    }
    
    // MARK: - 상태 초기화
    func reset() {
        stopListening()
        state = .idle
        matchedSong = nil
    }
    
    // MARK: - 마이크 권한 요청
    private func requestMicrophonePermission() async -> Bool {
        let status = AVAudioApplication.shared.recordPermission
        
        switch status {
        case .granted:
            return true
        case .denied:
            return false
        case .undetermined:
            return await withCheckedContinuation { continuation in
                AVAudioApplication.requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        @unknown default:
            return false
        }
    }
}
