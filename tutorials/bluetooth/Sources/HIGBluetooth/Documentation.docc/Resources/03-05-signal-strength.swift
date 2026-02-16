import SwiftUI

enum SignalStrength {
    case excellent  // -50 이상
    case good       // -50 ~ -65
    case fair       // -65 ~ -80
    case weak       // -80 이하
    
    init(rssi: Int) {
        switch rssi {
        case -50...:
            self = .excellent
        case -65..<(-50):
            self = .good
        case -80..<(-65):
            self = .fair
        default:
            self = .weak
        }
    }
    
    var iconName: String {
        switch self {
        case .excellent: return "wifi"
        case .good: return "wifi"
        case .fair: return "wifi.exclamationmark"
        case .weak: return "wifi.slash"
        }
    }
    
    var color: Color {
        switch self {
        case .excellent: return .green
        case .good: return .blue
        case .fair: return .orange
        case .weak: return .red
        }
    }
    
    var bars: Int {
        switch self {
        case .excellent: return 4
        case .good: return 3
        case .fair: return 2
        case .weak: return 1
        }
    }
}
