import Foundation

enum AlarmOption: String, CaseIterable, Identifiable {
    case none = "없음"
    case atTime = "이벤트 시간"
    case minutes5 = "5분 전"
    case minutes15 = "15분 전"
    case minutes30 = "30분 전"
    case hour1 = "1시간 전"
    case day1 = "1일 전"
    
    var id: String { rawValue }
    
    var offset: TimeInterval? {
        switch self {
        case .none: return nil
        case .atTime: return 0
        case .minutes5: return -5 * 60
        case .minutes15: return -15 * 60
        case .minutes30: return -30 * 60
        case .hour1: return -60 * 60
        case .day1: return -24 * 60 * 60
        }
    }
}
