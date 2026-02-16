import Foundation

// 음악 인식의 다양한 상태
enum RecognitionState: Equatable {
    case idle           // 대기 중
    case requestingPermission  // 권한 요청 중
    case listening      // 듣고 있음 (마이크 녹음 중)
    case matching       // 매칭 중 (서버와 통신)
    case matched        // 매칭 성공!
    case noMatch        // 매칭 실패 (카탈로그에 없음)
    case error(String)  // 오류 발생
    
    var description: String {
        switch self {
        case .idle: return "탭하여 시작"
        case .requestingPermission: return "권한 요청 중..."
        case .listening: return "듣고 있습니다..."
        case .matching: return "찾고 있습니다..."
        case .matched: return "찾았습니다!"
        case .noMatch: return "찾을 수 없습니다"
        case .error(let msg): return "오류: \(msg)"
        }
    }
}
