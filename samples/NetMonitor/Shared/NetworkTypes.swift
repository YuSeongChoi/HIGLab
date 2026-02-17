import Foundation
import Network

// MARK: - 네트워크 연결 유형
/// 현재 네트워크 연결의 유형을 나타냄
enum NetworkConnectionType: String, CaseIterable, Identifiable {
    case wifi = "Wi-Fi"
    case cellular = "셀룰러"
    case wiredEthernet = "이더넷"
    case loopback = "루프백"
    case other = "기타"
    case none = "연결 없음"
    
    var id: String { rawValue }
    
    /// SF Symbol 아이콘 이름
    var iconName: String {
        switch self {
        case .wifi: return "wifi"
        case .cellular: return "antenna.radiowaves.left.and.right"
        case .wiredEthernet: return "cable.connector"
        case .loopback: return "arrow.triangle.2.circlepath"
        case .other: return "network"
        case .none: return "wifi.slash"
        }
    }
    
    /// NWInterface.InterfaceType에서 변환
    static func from(_ interfaceType: NWInterface.InterfaceType) -> NetworkConnectionType {
        switch interfaceType {
        case .wifi: return .wifi
        case .cellular: return .cellular
        case .wiredEthernet: return .wiredEthernet
        case .loopback: return .loopback
        case .other: return .other
        @unknown default: return .other
        }
    }
}

// MARK: - 네트워크 인터페이스 정보
/// 개별 네트워크 인터페이스에 대한 정보
struct NetworkInterfaceInfo: Identifiable, Hashable {
    let id: String
    let name: String
    let type: NetworkConnectionType
    let isExpensive: Bool      // 비용이 발생하는 연결인지 (셀룰러 등)
    let isConstrained: Bool    // 저데이터 모드인지
    
    /// NWInterface에서 생성
    init(from interface: NWInterface) {
        self.id = interface.name
        self.name = interface.name
        self.type = NetworkConnectionType.from(interface.type)
        self.isExpensive = false  // NWPath에서 확인 필요
        self.isConstrained = false
    }
    
    /// 직접 생성
    init(id: String, name: String, type: NetworkConnectionType, isExpensive: Bool, isConstrained: Bool) {
        self.id = id
        self.name = name
        self.type = type
        self.isExpensive = isExpensive
        self.isConstrained = isConstrained
    }
}

// MARK: - 연결 프로토콜 유형
/// TCP 또는 UDP 연결 프로토콜
enum ConnectionProtocol: String, CaseIterable, Identifiable {
    case tcp = "TCP"
    case udp = "UDP"
    
    var id: String { rawValue }
    
    /// 해당 프로토콜의 NWParameters 생성
    var nwParameters: NWParameters {
        switch self {
        case .tcp: return .tcp
        case .udp: return .udp
        }
    }
    
    /// 아이콘 이름
    var iconName: String {
        switch self {
        case .tcp: return "arrow.left.arrow.right"
        case .udp: return "arrow.up.arrow.down"
        }
    }
}

// MARK: - 연결 품질 등급
/// 네트워크 연결 품질을 나타내는 등급
enum ConnectionQuality: String, CaseIterable {
    case excellent = "우수"
    case good = "양호"
    case fair = "보통"
    case poor = "불량"
    case none = "연결 없음"
    
    /// 품질에 따른 색상
    var colorName: String {
        switch self {
        case .excellent: return "green"
        case .good: return "blue"
        case .fair: return "yellow"
        case .poor: return "orange"
        case .none: return "red"
        }
    }
    
    /// 신호 강도 막대 개수 (0-4)
    var signalBars: Int {
        switch self {
        case .excellent: return 4
        case .good: return 3
        case .fair: return 2
        case .poor: return 1
        case .none: return 0
        }
    }
}

// MARK: - 에코 메시지
/// 에코 서버/클라이언트 간 주고받는 메시지
struct EchoMessage: Identifiable, Equatable {
    let id: UUID
    let content: String
    let timestamp: Date
    let isOutgoing: Bool  // true: 보낸 메시지, false: 받은 메시지
    
    init(content: String, isOutgoing: Bool) {
        self.id = UUID()
        self.content = content
        self.timestamp = Date()
        self.isOutgoing = isOutgoing
    }
    
    /// 포맷된 시간 문자열
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: timestamp)
    }
}

// MARK: - 서버 상태
/// 에코 서버의 현재 상태
enum ServerState: Equatable {
    case stopped
    case starting
    case running(port: UInt16)
    case error(String)
    
    var isRunning: Bool {
        if case .running = self { return true }
        return false
    }
    
    var statusText: String {
        switch self {
        case .stopped: return "중지됨"
        case .starting: return "시작 중..."
        case .running(let port): return "실행 중 (포트: \(port))"
        case .error(let message): return "오류: \(message)"
        }
    }
}
