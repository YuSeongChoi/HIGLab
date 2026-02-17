import Foundation
import CallKit
import AVFoundation

// MARK: - ProviderDelegate
// CXProviderDelegate 프로토콜 구현
// 시스템과 앱 간의 통화 이벤트를 중개

/// CXProvider 델리게이트 클래스
class ProviderDelegate: NSObject, CXProviderDelegate {
    
    /// CallManager 참조 (weak 참조로 순환 참조 방지)
    private weak var callManager: CallManager?
    
    /// 오디오 세션
    private let audioSession = AVAudioSession.sharedInstance()
    
    // MARK: - 초기화
    
    init(callManager: CallManager) {
        self.callManager = callManager
        super.init()
    }
    
    // MARK: - CXProviderDelegate 필수 메서드
    
    /// Provider 리셋 시 호출
    /// 모든 통화가 무효화될 때 정리 작업 수행
    func providerDidReset(_ provider: CXProvider) {
        print("Provider 리셋됨")
        
        // 오디오 세션 비활성화
        deactivateAudioSession()
        
        // 현재 통화 정리
        if let call = callManager?.currentCall {
            callManager?.handleCallEnded(call)
        }
    }
    
    // MARK: - 발신 전화 처리
    
    /// 발신 전화 시작 요청
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        print("발신 전화 시작: \(action.handle.value)")
        
        // 오디오 세션 설정
        configureAudioSession()
        
        // 발신 시작 알림
        provider.reportOutgoingCall(with: action.callUUID, startedConnectingAt: Date())
        
        // 실제 VoIP 서버 연결 시뮬레이션
        // 프로덕션에서는 실제 VoIP 연결 로직 구현
        simulateOutgoingConnection { [weak self] success in
            if success {
                // 연결 성공
                self?.callManager?.simulateOutgoingCallConnected()
                action.fulfill()
            } else {
                // 연결 실패
                action.fail()
            }
        }
    }
    
    /// 발신 연결 시뮬레이션
    private func simulateOutgoingConnection(completion: @escaping (Bool) -> Void) {
        // 2초 후 연결 성공 시뮬레이션
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            completion(true)
        }
    }
    
    // MARK: - 수신 전화 처리
    
    /// 수신 전화 응답 요청
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        print("수신 전화 응답: \(action.callUUID)")
        
        // 오디오 세션 설정
        configureAudioSession()
        
        // 응답 성공
        action.fulfill()
    }
    
    // MARK: - 통화 종료 처리
    
    /// 통화 종료 요청
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        print("통화 종료: \(action.callUUID)")
        
        // 오디오 세션 비활성화
        deactivateAudioSession()
        
        // 종료 처리
        if let call = callManager?.currentCall, call.id == action.callUUID {
            callManager?.handleCallEnded(call)
        }
        
        action.fulfill()
    }
    
    // MARK: - 음소거 처리
    
    /// 음소거 설정 요청
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        print("음소거 설정: \(action.isMuted)")
        
        // 실제 VoIP에서는 마이크 음소거 처리
        // 여기서는 상태 업데이트만 수행
        
        action.fulfill()
    }
    
    // MARK: - 보류 처리
    
    /// 보류 설정 요청
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        print("보류 설정: \(action.isOnHold)")
        
        // 보류 시 오디오 일시 정지
        if action.isOnHold {
            // 보류 음악 재생 또는 오디오 중지
        } else {
            // 오디오 재개
        }
        
        action.fulfill()
    }
    
    // MARK: - DTMF 처리
    
    /// DTMF 톤 재생 요청
    func provider(_ provider: CXProvider, perform action: CXPlayDTMFCallAction) {
        print("DTMF 톤: \(action.digits)")
        
        // DTMF 톤 재생 및 서버로 전송
        // 실제 VoIP에서는 SIP INFO 또는 RTP로 전송
        
        action.fulfill()
    }
    
    // MARK: - 오디오 세션 설정
    
    /// Provider 오디오 세션 시작
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        print("오디오 세션 활성화됨")
        
        // 오디오 시작
        // 실제 VoIP에서는 오디오 스트림 시작
    }
    
    /// Provider 오디오 세션 종료
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        print("오디오 세션 비활성화됨")
        
        // 오디오 정리
    }
    
    // MARK: - 오디오 세션 관리
    
    /// 오디오 세션 설정
    private func configureAudioSession() {
        do {
            // VoIP 모드로 오디오 세션 설정
            try audioSession.setCategory(
                .playAndRecord,
                mode: .voiceChat,
                options: [.allowBluetooth, .allowBluetoothA2DP]
            )
            
            // 오디오 세션 활성화
            try audioSession.setActive(true)
            
            print("오디오 세션 설정 완료")
        } catch {
            print("오디오 세션 설정 실패: \(error.localizedDescription)")
        }
    }
    
    /// 오디오 세션 비활성화
    private func deactivateAudioSession() {
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
            print("오디오 세션 비활성화 완료")
        } catch {
            print("오디오 세션 비활성화 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 타임아웃 처리
    
    /// 액션 타임아웃 시 호출
    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        print("액션 타임아웃: \(type(of: action))")
        
        // 타임아웃된 액션 처리
        // 필요시 사용자에게 알림
    }
}
