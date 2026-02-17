import Foundation
import CallKit
import AVFoundation
import Combine

// MARK: - CallManager
// CXProvider와 CXCallController를 관리하는 핵심 클래스
// 모든 통화 관련 동작을 중앙에서 처리

/// 통화 관리자 클래스
class CallManager: NSObject, ObservableObject {
    // 싱글톤 인스턴스
    static let shared = CallManager()
    
    // MARK: - Published 속성
    
    /// 현재 활성 통화
    @Published var currentCall: Call?
    
    /// 수신 전화 여부
    @Published var hasIncomingCall: Bool = false
    
    /// 통화 시간 (초)
    @Published var callDuration: TimeInterval = 0
    
    // MARK: - CallKit 구성요소
    
    /// CXProvider - 시스템에 통화 정보를 제공
    private var provider: CXProvider!
    
    /// CXCallController - 통화 액션을 시스템에 요청
    private let callController = CXCallController()
    
    // MARK: - 내부 속성
    
    /// 통화 시간 타이머
    private var callTimer: Timer?
    
    /// Provider 델리게이트
    private var providerDelegate: ProviderDelegate?
    
    /// 연락처 저장소 참조
    private let contactStore = ContactStore.shared
    
    /// 통화 기록 저장소 참조
    private let historyStore = CallHistoryStore.shared
    
    // MARK: - 초기화
    
    private override init() {
        super.init()
    }
    
    /// Provider 설정
    func setupProvider() {
        // Provider 설정 구성
        let configuration = CXProviderConfiguration()
        configuration.localizedName = "VoIP Phone"
        configuration.supportsVideo = false
        configuration.maximumCallsPerCallGroup = 1
        configuration.maximumCallGroups = 1
        configuration.supportedHandleTypes = [.phoneNumber]
        configuration.iconTemplateImageData = nil  // 앱 아이콘 사용
        
        // 벨소리 설정 (기본 벨소리 사용)
        // configuration.ringtoneSound = "custom_ringtone.caf"
        
        // Provider 생성 및 델리게이트 설정
        provider = CXProvider(configuration: configuration)
        providerDelegate = ProviderDelegate(callManager: self)
        provider.setDelegate(providerDelegate, queue: .main)
        
        print("CallKit Provider 설정 완료")
    }
    
    // MARK: - 발신 전화
    
    /// 전화 걸기
    func startCall(to phoneNumber: String) {
        // 연락처에서 이름 찾기
        let contact = contactStore.findContact(byPhoneNumber: phoneNumber)
        
        // 통화 객체 생성
        let call = Call(
            remotePhoneNumber: phoneNumber,
            remoteName: contact?.name,
            direction: .outgoing,
            state: .connecting
        )
        
        // CXHandle 생성
        let handle = CXHandle(type: .phoneNumber, value: phoneNumber)
        
        // 발신 액션 생성
        let startCallAction = CXStartCallAction(call: call.id, handle: handle)
        startCallAction.isVideo = false
        
        // 트랜잭션 요청
        let transaction = CXTransaction(action: startCallAction)
        requestTransaction(transaction) { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    self?.currentCall = call
                }
            }
        }
    }
    
    /// 발신 연결됨 (시뮬레이션용)
    func simulateOutgoingCallConnected() {
        guard var call = currentCall, call.direction == .outgoing else { return }
        
        // 연결 완료 리포트
        provider.reportOutgoingCall(with: call.id, connectedAt: Date())
        
        // 상태 업데이트
        call.state = .active
        call.connectedTime = Date()
        currentCall = call
        
        // 타이머 시작
        startCallTimer()
    }
    
    // MARK: - 수신 전화
    
    /// 수신 전화 리포트 (VoIP 푸시 수신 시 호출)
    func reportIncomingCall(
        phoneNumber: String,
        callerName: String? = nil,
        completion: ((Error?) -> Void)? = nil
    ) {
        // 연락처에서 이름 찾기
        let contact = contactStore.findContact(byPhoneNumber: phoneNumber)
        let displayName = callerName ?? contact?.name ?? phoneNumber
        
        // 통화 객체 생성
        let call = Call(
            remotePhoneNumber: phoneNumber,
            remoteName: displayName,
            direction: .incoming,
            state: .incoming
        )
        
        // 업데이트 정보 구성
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .phoneNumber, value: phoneNumber)
        update.localizedCallerName = displayName
        update.hasVideo = false
        update.supportsHolding = true
        update.supportsGrouping = false
        update.supportsUngrouping = false
        update.supportsDTMF = true
        
        // Provider에 수신 전화 리포트
        provider.reportNewIncomingCall(with: call.id, update: update) { [weak self] error in
            if let error = error {
                print("수신 전화 리포트 실패: \(error.localizedDescription)")
                completion?(error)
            } else {
                DispatchQueue.main.async {
                    self?.currentCall = call
                    self?.hasIncomingCall = true
                }
                completion?(nil)
            }
        }
    }
    
    /// 수신 전화 응답
    func answerCall() {
        guard let call = currentCall else { return }
        
        let answerAction = CXAnswerCallAction(call: call.id)
        let transaction = CXTransaction(action: answerAction)
        
        requestTransaction(transaction) { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    self?.hasIncomingCall = false
                    var updatedCall = call
                    updatedCall.state = .active
                    updatedCall.connectedTime = Date()
                    self?.currentCall = updatedCall
                    self?.startCallTimer()
                }
            }
        }
    }
    
    // MARK: - 통화 종료
    
    /// 통화 종료
    func endCall() {
        guard let call = currentCall else { return }
        
        let endAction = CXEndCallAction(call: call.id)
        let transaction = CXTransaction(action: endAction)
        
        requestTransaction(transaction) { [weak self] success in
            if success {
                self?.handleCallEnded(call)
            }
        }
    }
    
    /// 통화 종료 처리
    func handleCallEnded(_ call: Call) {
        // 타이머 중지
        stopCallTimer()
        
        // 통화 결과 결정
        var result: CallResult = .completed
        if call.connectedTime == nil {
            if call.direction == .incoming {
                result = hasIncomingCall ? .missed : .declined
            } else {
                result = .cancelled
            }
        }
        
        // 기록 저장
        var finalCall = call
        finalCall.endTime = Date()
        historyStore.addEntry(from: finalCall, result: result)
        
        // 상태 초기화
        DispatchQueue.main.async { [weak self] in
            self?.currentCall = nil
            self?.hasIncomingCall = false
            self?.callDuration = 0
        }
    }
    
    // MARK: - 통화 중 기능
    
    /// 음소거 토글
    func toggleMute() {
        guard var call = currentCall else { return }
        
        let newMuteState = !call.isMuted
        let muteAction = CXSetMutedCallAction(call: call.id, muted: newMuteState)
        let transaction = CXTransaction(action: muteAction)
        
        requestTransaction(transaction) { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    call.isMuted = newMuteState
                    self?.currentCall = call
                }
            }
        }
    }
    
    /// 보류 토글
    func toggleHold() {
        guard var call = currentCall else { return }
        
        let newHoldState = !call.isOnHold
        let holdAction = CXSetHeldCallAction(call: call.id, onHold: newHoldState)
        let transaction = CXTransaction(action: holdAction)
        
        requestTransaction(transaction) { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    call.isOnHold = newHoldState
                    call.state = newHoldState ? .holding : .active
                    self?.currentCall = call
                }
            }
        }
    }
    
    /// 스피커 토글
    func toggleSpeaker() {
        guard var call = currentCall else { return }
        
        let newSpeakerState = !call.isSpeakerOn
        
        // 오디오 세션 설정
        let audioSession = AVAudioSession.sharedInstance()
        do {
            if newSpeakerState {
                try audioSession.overrideOutputAudioPort(.speaker)
            } else {
                try audioSession.overrideOutputAudioPort(.none)
            }
            
            DispatchQueue.main.async { [weak self] in
                call.isSpeakerOn = newSpeakerState
                self?.currentCall = call
            }
        } catch {
            print("스피커 전환 실패: \(error.localizedDescription)")
        }
    }
    
    /// DTMF 톤 전송
    func sendDTMF(digit: String) {
        guard let call = currentCall else { return }
        
        let dtmfAction = CXPlayDTMFCallAction(
            call: call.id,
            digits: digit,
            type: .singleTone
        )
        let transaction = CXTransaction(action: dtmfAction)
        
        requestTransaction(transaction) { success in
            if success {
                // 햅틱 피드백
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
            }
        }
    }
    
    // MARK: - 트랜잭션 처리
    
    /// CXTransaction 요청
    private func requestTransaction(
        _ transaction: CXTransaction,
        completion: @escaping (Bool) -> Void
    ) {
        callController.request(transaction) { error in
            if let error = error {
                print("트랜잭션 요청 실패: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    // MARK: - 타이머
    
    /// 통화 시간 타이머 시작
    private func startCallTimer() {
        callTimer?.invalidate()
        callDuration = 0
        
        callTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.callDuration += 1
            }
        }
    }
    
    /// 통화 시간 타이머 중지
    private func stopCallTimer() {
        callTimer?.invalidate()
        callTimer = nil
    }
    
    // MARK: - 시뮬레이션 (테스트용)
    
    /// 테스트용 수신 전화 시뮬레이션
    func simulateIncomingCall(from phoneNumber: String = "01012345678") {
        reportIncomingCall(phoneNumber: phoneNumber) { error in
            if let error = error {
                print("시뮬레이션 수신 전화 실패: \(error.localizedDescription)")
            }
        }
    }
}
