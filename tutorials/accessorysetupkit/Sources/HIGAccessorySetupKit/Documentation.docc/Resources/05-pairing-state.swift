import Foundation

// 페어링 상태 정의
enum PairingState: Equatable {
    case idle           // 초기 상태
    case ready          // 세션 활성화됨
    case discovering    // 피커 표시 중
    case pairing        // 페어링 진행 중
    case paired         // 페어링 완료
    case failed(String) // 실패
    
    var description: String {
        switch self {
        case .idle:
            return "대기 중"
        case .ready:
            return "준비됨"
        case .discovering:
            return "기기 검색 중..."
        case .pairing:
            return "페어링 중..."
        case .paired:
            return "연결됨"
        case .failed(let reason):
            return "실패: \(reason)"
        }
    }
    
    var canShowPicker: Bool {
        self == .ready
    }
    
    var isConnected: Bool {
        self == .paired
    }
}
