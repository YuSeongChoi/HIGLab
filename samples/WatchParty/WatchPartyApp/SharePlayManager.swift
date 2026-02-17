import Foundation
import GroupActivities
import Combine
import AVFoundation

// MARK: - SharePlay 매니저
// GroupActivity 세션 및 동기화를 관리하는 핵심 클래스

@MainActor
final class SharePlayManager: ObservableObject {
    
    // MARK: - Published 속성
    
    /// 현재 세션 상태
    @Published private(set) var sessionState: SharePlaySessionState = .idle
    
    /// 현재 재생 상태
    @Published private(set) var playbackState: PlaybackState = .initial
    
    /// 참여자 목록
    @Published private(set) var participants: [WatchPartyParticipant] = []
    
    /// 받은 반응들
    @Published private(set) var reactions: [ReactionMessage] = []
    
    /// 채팅 메시지들
    @Published private(set) var chatMessages: [ChatMessage] = []
    
    /// 에러 메시지
    @Published var errorMessage: String?
    
    /// 세션 설정
    @Published var configuration = SessionConfiguration.default
    
    // MARK: - Private 속성
    
    /// 현재 활성 세션
    private var groupSession: GroupSession<WatchPartyActivity>?
    
    /// 메시지 채널 - 재생 제어
    private var playbackChannel: GroupSessionMessenger?
    
    /// 메시지 채널 - 반응
    private var reactionChannel: GroupSessionMessenger?
    
    /// 메시지 채널 - 채팅
    private var chatChannel: GroupSessionMessenger?
    
    /// 구독 취소 토큰들
    private var cancellables = Set<AnyCancellable>()
    
    /// 세션 관련 작업들
    private var tasks = Set<Task<Void, Never>>()
    
    /// 로컬 참여자 ID
    private var localParticipantId: String = UUID().uuidString
    
    // MARK: - 초기화
    
    init() {
        // 초기화 로그
        print("[SharePlayManager] 초기화됨")
    }
    
    deinit {
        // 모든 작업 취소
        tasks.forEach { $0.cancel() }
    }
    
    // MARK: - 세션 관리
    
    /// 새 GroupActivity 세션 설정
    func configureSession(_ session: GroupSession<WatchPartyActivity>) async {
        // 기존 세션 정리
        cleanupSession()
        
        // 새 세션 저장
        groupSession = session
        
        // 메시지 채널 설정
        setupMessengers(for: session)
        
        // 세션 상태 구독
        subscribeToSessionState(session)
        
        // 참여자 변경 구독
        subscribeToParticipants(session)
        
        // 초기 비디오 설정
        let activity = session.activity
        playbackState = playbackState.withVideo(activity.video)
        
        // 세션 참여 (자동으로 다른 참여자와 연결)
        session.join()
        
        print("[SharePlayManager] 세션 참여 완료: \(activity.video.title)")
    }
    
    /// 메시지 채널 설정
    private func setupMessengers(for session: GroupSession<WatchPartyActivity>) {
        // 재생 제어 메시지 (신뢰성 높은 전송)
        playbackChannel = GroupSessionMessenger(session: session)
        
        // 반응 메시지 (신뢰성 낮아도 됨)
        reactionChannel = GroupSessionMessenger(
            session: session,
            deliveryMode: .unreliable
        )
        
        // 채팅 메시지
        chatChannel = GroupSessionMessenger(session: session)
        
        // 메시지 수신 설정
        setupMessageHandlers()
    }
    
    /// 메시지 핸들러 설정
    private func setupMessageHandlers() {
        // 재생 제어 메시지 수신
        let playbackTask = Task { [weak self] in
            guard let messenger = self?.playbackChannel else { return }
            
            for await (message, _) in messenger.messages(of: PlaybackControlMessage.self) {
                await self?.handlePlaybackControl(message)
            }
        }
        tasks.insert(playbackTask)
        
        // 반응 메시지 수신
        let reactionTask = Task { [weak self] in
            guard let messenger = self?.reactionChannel else { return }
            
            for await (message, _) in messenger.messages(of: ReactionMessage.self) {
                await self?.handleReaction(message)
            }
        }
        tasks.insert(reactionTask)
        
        // 채팅 메시지 수신
        let chatTask = Task { [weak self] in
            guard let messenger = self?.chatChannel else { return }
            
            for await (message, _) in messenger.messages(of: ChatMessage.self) {
                await self?.handleChatMessage(message)
            }
        }
        tasks.insert(chatTask)
    }
    
    /// 세션 상태 구독
    private func subscribeToSessionState(_ session: GroupSession<WatchPartyActivity>) {
        session.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleSessionStateChange(state)
            }
            .store(in: &cancellables)
    }
    
    /// 참여자 변경 구독
    private func subscribeToParticipants(_ session: GroupSession<WatchPartyActivity>) {
        session.$activeParticipants
            .receive(on: DispatchQueue.main)
            .sink { [weak self] activeParticipants in
                self?.updateParticipants(from: activeParticipants)
            }
            .store(in: &cancellables)
    }
    
    /// 세션 상태 변경 처리
    private func handleSessionStateChange(_ state: GroupSession<WatchPartyActivity>.State) {
        switch state {
        case .waiting:
            sessionState = .waitingForActivation
        case .joined:
            sessionState = .active(participantCount: participants.count)
        case .invalidated(let reason):
            print("[SharePlayManager] 세션 종료됨: \(reason)")
            sessionState = .idle
            cleanupSession()
        @unknown default:
            break
        }
    }
    
    /// 참여자 목록 업데이트
    private func updateParticipants(from activeParticipants: Set<Participant>) {
        participants = activeParticipants.map { WatchPartyParticipant(from: $0) }
        
        // 세션 상태 업데이트
        if case .active = sessionState {
            sessionState = .active(participantCount: participants.count)
        }
        
        print("[SharePlayManager] 참여자 수: \(participants.count)")
    }
    
    /// 세션 정리
    private func cleanupSession() {
        // 작업 취소
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
        
        // 구독 취소
        cancellables.removeAll()
        
        // 채널 정리
        playbackChannel = nil
        reactionChannel = nil
        chatChannel = nil
        
        // 세션 종료
        groupSession?.leave()
        groupSession = nil
        
        // 상태 초기화
        participants.removeAll()
        reactions.removeAll()
    }
    
    // MARK: - SharePlay 시작
    
    /// 비디오로 SharePlay 시작
    func startSharePlay(with video: Video) async {
        // 활동 생성
        let activity = WatchPartyActivity(video: video)
        
        do {
            // 활동 활성화 시도
            let result = try await activity.activate()
            
            switch result {
            case .activationPreferred:
                // SharePlay가 가능하고 선호됨
                print("[SharePlayManager] SharePlay 활성화됨")
                sessionState = .waitingForActivation
                
            case .activationDisabled:
                // SharePlay 비활성화됨 (FaceTime 통화 없음)
                print("[SharePlayManager] SharePlay 비활성화 - 로컬 재생")
                sessionState = .localOnly
                playbackState = playbackState.withVideo(video)
                
            case .cancelled:
                // 사용자가 취소
                print("[SharePlayManager] 사용자가 취소함")
                
            @unknown default:
                break
            }
        } catch {
            errorMessage = "SharePlay 시작 실패: \(error.localizedDescription)"
            print("[SharePlayManager] 에러: \(error)")
        }
    }
    
    /// 세션 종료
    func endSession() {
        groupSession?.end()
        cleanupSession()
        sessionState = .idle
        playbackState = .initial
    }
    
    // MARK: - 재생 제어
    
    /// 재생/일시정지 토글
    func togglePlayback() async {
        playbackState = playbackState.togglePlayback(changedBy: localParticipantId)
        await sendPlaybackControl(playbackState.isPlaying ? .play : .pause)
    }
    
    /// 재생
    func play() async {
        guard !playbackState.isPlaying else { return }
        playbackState = playbackState.togglePlayback(changedBy: localParticipantId)
        await sendPlaybackControl(.play)
    }
    
    /// 일시정지
    func pause() async {
        guard playbackState.isPlaying else { return }
        playbackState = playbackState.togglePlayback(changedBy: localParticipantId)
        await sendPlaybackControl(.pause)
    }
    
    /// 특정 위치로 이동
    func seek(to time: TimeInterval) async {
        playbackState = playbackState.seek(to: time, changedBy: localParticipantId)
        await sendPlaybackControl(.seek(time: time))
    }
    
    /// 재생 속도 변경
    func setPlaybackRate(_ rate: Float) async {
        playbackState = playbackState.withRate(rate, changedBy: localParticipantId)
        await sendPlaybackControl(.setRate(rate: rate))
    }
    
    /// 비디오 변경
    func changeVideo(_ video: Video) async {
        playbackState = playbackState.withVideo(video, changedBy: localParticipantId)
        
        // 새 활동 시작
        await startSharePlay(with: video)
    }
    
    /// 재생 제어 메시지 전송
    private func sendPlaybackControl(_ action: PlaybackAction) async {
        guard let messenger = playbackChannel else { return }
        
        let message = PlaybackControlMessage(
            action: action,
            senderId: localParticipantId
        )
        
        do {
            try await messenger.send(message)
        } catch {
            print("[SharePlayManager] 재생 제어 전송 실패: \(error)")
        }
    }
    
    /// 재생 제어 메시지 처리
    private func handlePlaybackControl(_ message: PlaybackControlMessage) async {
        // 자신이 보낸 메시지는 무시
        guard message.senderId != localParticipantId else { return }
        
        switch message.action {
        case .play:
            playbackState = PlaybackState(
                video: playbackState.video,
                isPlaying: true,
                currentTime: playbackState.currentTime,
                playbackRate: playbackState.playbackRate,
                changedBy: message.senderId
            )
            
        case .pause:
            playbackState = PlaybackState(
                video: playbackState.video,
                isPlaying: false,
                currentTime: playbackState.currentTime,
                playbackRate: playbackState.playbackRate,
                changedBy: message.senderId
            )
            
        case .seek(let time):
            playbackState = playbackState.seek(to: time, changedBy: message.senderId)
            
        case .setRate(let rate):
            playbackState = playbackState.withRate(rate, changedBy: message.senderId)
        }
    }
    
    // MARK: - 반응 & 채팅
    
    /// 반응 보내기
    func sendReaction(_ emoji: String) async {
        guard let messenger = reactionChannel else { return }
        
        let message = ReactionMessage(emoji: emoji, senderId: localParticipantId)
        
        do {
            try await messenger.send(message)
            // 자신의 반응도 표시
            await handleReaction(message)
        } catch {
            print("[SharePlayManager] 반응 전송 실패: \(error)")
        }
    }
    
    /// 반응 처리
    private func handleReaction(_ message: ReactionMessage) async {
        reactions.append(message)
        
        // 일정 시간 후 제거
        Task {
            try? await Task.sleep(for: .seconds(AppConstants.reactionDisplayDuration))
            await MainActor.run {
                reactions.removeAll { $0.timestamp == message.timestamp && $0.senderId == message.senderId }
            }
        }
    }
    
    /// 채팅 메시지 보내기
    func sendChatMessage(_ text: String, senderName: String) async {
        guard let messenger = chatChannel else { return }
        
        let message = ChatMessage(
            text: text,
            senderId: localParticipantId,
            senderName: senderName
        )
        
        do {
            try await messenger.send(message)
            // 자신의 메시지도 추가
            chatMessages.append(message)
        } catch {
            print("[SharePlayManager] 채팅 전송 실패: \(error)")
        }
    }
    
    /// 채팅 메시지 처리
    private func handleChatMessage(_ message: ChatMessage) async {
        // 자신이 보낸 메시지는 이미 추가됨
        guard message.senderId != localParticipantId else { return }
        chatMessages.append(message)
    }
    
    // MARK: - 현재 시간 업데이트
    
    /// 재생 위치 업데이트 (로컬 플레이어에서 호출)
    func updateCurrentTime(_ time: TimeInterval) {
        playbackState = playbackState.withCurrentTime(time)
    }
}
