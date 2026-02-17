import Foundation
import GroupActivities
import Combine

// MARK: - 그룹 상태 관찰자
// FaceTime 통화 상태 및 SharePlay 가용성을 모니터링

@MainActor
final class GroupStateObserver: ObservableObject {
    
    // MARK: - Published 속성
    
    /// SharePlay 사용 가능 여부
    @Published private(set) var isSharePlayAvailable: Bool = false
    
    /// FaceTime 통화 중 여부
    @Published private(set) var isInFaceTimeCall: Bool = false
    
    /// 활성화된 SharePlay 세션 존재 여부
    @Published private(set) var hasActiveSession: Bool = false
    
    /// 그룹 세션이 대기 중인지 여부
    @Published private(set) var isWaitingForOthers: Bool = false
    
    /// 참여 가능한 활동 정보
    @Published private(set) var pendingActivity: WatchPartyActivity?
    
    // MARK: - Private 속성
    
    /// 그룹 상태 관찰자
    private var groupStateObserver: GroupStateObserver.StateObserver?
    
    /// 구독 취소 토큰들
    private var cancellables = Set<AnyCancellable>()
    
    /// 세션 감시 작업
    private var sessionTask: Task<Void, Never>?
    
    // MARK: - 초기화
    
    init() {
        setupGroupStateObservation()
    }
    
    deinit {
        sessionTask?.cancel()
    }
    
    // MARK: - 상태 관찰 설정
    
    /// 그룹 상태 관찰 설정
    private func setupGroupStateObservation() {
        // GroupStateObserver 생성
        let observer = StateObserver()
        self.groupStateObserver = observer
        
        // 자격(entitlement) 상태 관찰
        // SharePlay가 시스템에서 활성화되어 있는지 확인
        observer.$isEligibleForGroupSession
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEligible in
                self?.isSharePlayAvailable = isEligible
                self?.isInFaceTimeCall = isEligible
                print("[GroupStateObserver] SharePlay 사용 가능: \(isEligible)")
            }
            .store(in: &cancellables)
        
        // 세션 감시 시작
        startSessionObservation()
    }
    
    /// 세션 감시 시작
    private func startSessionObservation() {
        sessionTask = Task { [weak self] in
            // WatchPartyActivity 세션 감시
            for await session in WatchPartyActivity.sessions() {
                await self?.handleNewSession(session)
            }
        }
    }
    
    /// 새 세션 처리
    private func handleNewSession(_ session: GroupSession<WatchPartyActivity>) async {
        hasActiveSession = true
        pendingActivity = session.activity
        
        // 세션 상태 구독
        subscribeToSession(session)
    }
    
    /// 세션 상태 구독
    private func subscribeToSession(_ session: GroupSession<WatchPartyActivity>) {
        session.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .waiting:
                    self?.isWaitingForOthers = true
                case .joined:
                    self?.isWaitingForOthers = false
                    self?.hasActiveSession = true
                case .invalidated:
                    self?.hasActiveSession = false
                    self?.isWaitingForOthers = false
                    self?.pendingActivity = nil
                @unknown default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 상태 확인 메서드
    
    /// SharePlay를 시작할 수 있는지 확인
    var canStartSharePlay: Bool {
        isSharePlayAvailable && !hasActiveSession
    }
    
    /// 활동에 참여할 수 있는지 확인
    var canJoinActivity: Bool {
        pendingActivity != nil && !hasActiveSession
    }
    
    /// 현재 상태 설명
    var statusDescription: String {
        if hasActiveSession {
            return "SharePlay 세션 활성화됨"
        } else if isWaitingForOthers {
            return "다른 참여자 대기 중..."
        } else if isSharePlayAvailable {
            return "SharePlay 준비됨"
        } else {
            return "FaceTime 통화를 시작하세요"
        }
    }
    
    /// 상태 아이콘
    var statusIcon: String {
        if hasActiveSession {
            return "shareplay"
        } else if isWaitingForOthers {
            return "person.2.wave.2"
        } else if isSharePlayAvailable {
            return "shareplay.slash"
        } else {
            return "video.slash"
        }
    }
}

// MARK: - StateObserver (GroupActivities 래퍼)
extension GroupStateObserver {
    /// GroupActivities의 GroupStateObserver를 래핑
    final class StateObserver: ObservableObject {
        
        /// SharePlay 세션에 참여할 자격이 있는지
        @Published var isEligibleForGroupSession: Bool = false
        
        private var observer: GroupActivities.GroupStateObserver?
        private var cancellables = Set<AnyCancellable>()
        
        init() {
            setupObserver()
        }
        
        private func setupObserver() {
            // GroupStateObserver 생성
            let groupObserver = GroupActivities.GroupStateObserver()
            self.observer = groupObserver
            
            // 자격 상태 관찰
            groupObserver.$isEligibleForGroupSession
                .receive(on: DispatchQueue.main)
                .assign(to: &$isEligibleForGroupSession)
        }
    }
}

// MARK: - SharePlay 상태 뷰 모델
/// UI에서 사용할 SharePlay 상태 정보
struct SharePlayStatus {
    let isAvailable: Bool
    let isActive: Bool
    let participantCount: Int
    let statusText: String
    let iconName: String
    
    /// SharePlay 비활성 상태
    static let inactive = SharePlayStatus(
        isAvailable: false,
        isActive: false,
        participantCount: 0,
        statusText: "SharePlay 사용 불가",
        iconName: "shareplay.slash"
    )
    
    /// FaceTime 통화 대기 중
    static let waitingForFaceTime = SharePlayStatus(
        isAvailable: false,
        isActive: false,
        participantCount: 0,
        statusText: "FaceTime 통화를 시작하세요",
        iconName: "video"
    )
}

// MARK: - 에러 타입
/// 그룹 상태 관련 에러
enum GroupStateError: Error, LocalizedError {
    case notInFaceTimeCall
    case sharePlayNotSupported
    case sessionCreationFailed
    case alreadyInSession
    
    var errorDescription: String? {
        switch self {
        case .notInFaceTimeCall:
            return "FaceTime 통화 중이 아닙니다. SharePlay를 사용하려면 FaceTime 통화를 시작하세요."
        case .sharePlayNotSupported:
            return "이 기기에서 SharePlay를 지원하지 않습니다."
        case .sessionCreationFailed:
            return "SharePlay 세션을 생성하지 못했습니다."
        case .alreadyInSession:
            return "이미 SharePlay 세션에 참여 중입니다."
        }
    }
}
