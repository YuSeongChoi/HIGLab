import GroupActivities
import AVFoundation
import Combine
import SwiftUI

// ============================================
// SharePlay 관리 ViewModel
// ============================================

@MainActor
@Observable
class SharePlayViewModel {
    // 상태
    var isSessionActive = false
    var currentMovie: Movie?
    var participantCount = 0
    
    // 플레이어
    let player = AVPlayer()
    
    // 내부 상태
    private var session: GroupSession<WatchTogetherActivity>?
    private var messenger: GroupSessionMessenger?
    private var subscriptions = Set<AnyCancellable>()
    private var tasks = Set<Task<Void, Never>>()
    
    // 세션 설정
    func configureSession(_ session: GroupSession<WatchTogetherActivity>) {
        // 기존 세션 정리
        cleanup()
        
        self.session = session
        self.currentMovie = session.activity.movie
        
        // Messenger 생성
        self.messenger = GroupSessionMessenger(session: session)
        
        // 상태 관찰
        observeSessionState(session)
        observeParticipants(session)
        
        // 세션 참여
        session.join()
    }
    
    private func observeSessionState(_ session: GroupSession<WatchTogetherActivity>) {
        session.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.isSessionActive = (state == .joined)
                
                if state == .invalidated {
                    self?.cleanup()
                }
            }
            .store(in: &subscriptions)
    }
    
    private func observeParticipants(_ session: GroupSession<WatchTogetherActivity>) {
        session.$activeParticipants
            .receive(on: DispatchQueue.main)
            .sink { [weak self] participants in
                self?.participantCount = participants.count
            }
            .store(in: &subscriptions)
    }
    
    // 정리
    func cleanup() {
        subscriptions.removeAll()
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
        session = nil
        messenger = nil
        isSessionActive = false
    }
    
    // 세션 종료
    func endSession() {
        session?.end()
        cleanup()
    }
    
    // 세션 떠나기 (세션은 유지)
    func leaveSession() {
        session?.leave()
        cleanup()
    }
}
