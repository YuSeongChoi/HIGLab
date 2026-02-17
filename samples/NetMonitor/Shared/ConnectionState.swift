import Foundation
import Network

// MARK: - 연결 상태
/// NWConnection의 상태를 추상화한 열거형
enum ConnectionState: Equatable {
    case idle
    case preparing
    case ready
    case waiting(String)
    case failed(String)
    case cancelled
    
    /// 사용자에게 표시할 상태 문자열
    var displayText: String {
        switch self {
        case .idle: return "대기 중"
        case .preparing: return "준비 중"
        case .ready: return "연결됨"
        case .waiting(let reason): return "대기 중: \(reason)"
        case .failed(let error): return "실패: \(error)"
        case .cancelled: return "취소됨"
        }
    }
    
    /// 상태 아이콘
    var iconName: String {
        switch self {
        case .idle: return "circle"
        case .preparing: return "circle.dotted"
        case .ready: return "checkmark.circle.fill"
        case .waiting: return "clock"
        case .failed: return "xmark.circle.fill"
        case .cancelled: return "minus.circle"
        }
    }
    
    /// 상태 색상
    var colorName: String {
        switch self {
        case .idle: return "gray"
        case .preparing: return "blue"
        case .ready: return "green"
        case .waiting: return "orange"
        case .failed: return "red"
        case .cancelled: return "gray"
        }
    }
    
    /// NWConnection.State에서 변환
    static func from(_ state: NWConnection.State) -> ConnectionState {
        switch state {
        case .setup:
            return .idle
        case .preparing:
            return .preparing
        case .ready:
            return .ready
        case .waiting(let error):
            return .waiting(error.localizedDescription)
        case .failed(let error):
            return .failed(error.localizedDescription)
        case .cancelled:
            return .cancelled
        @unknown default:
            return .idle
        }
    }
}

// MARK: - 네트워크 경로 상태
/// NWPath의 상태를 추상화
struct NetworkPathState: Equatable {
    let status: PathStatus
    let connectionType: NetworkConnectionType
    let isExpensive: Bool
    let isConstrained: Bool
    let supportsIPv4: Bool
    let supportsIPv6: Bool
    let supportsDNS: Bool
    let interfaces: [NetworkInterfaceInfo]
    
    /// 기본 초기값 (연결 없음)
    static let disconnected = NetworkPathState(
        status: .unsatisfied,
        connectionType: .none,
        isExpensive: false,
        isConstrained: false,
        supportsIPv4: false,
        supportsIPv6: false,
        supportsDNS: false,
        interfaces: []
    )
    
    /// NWPath에서 생성
    init(from path: NWPath) {
        switch path.status {
        case .satisfied:
            self.status = .satisfied
        case .unsatisfied:
            self.status = .unsatisfied
        case .requiresConnection:
            self.status = .requiresConnection
        @unknown default:
            self.status = .unsatisfied
        }
        
        // 주 연결 유형 결정 (첫 번째 인터페이스 기준)
        if let firstInterface = path.availableInterfaces.first {
            self.connectionType = NetworkConnectionType.from(firstInterface.type)
        } else {
            self.connectionType = .none
        }
        
        self.isExpensive = path.isExpensive
        self.isConstrained = path.isConstrained
        self.supportsIPv4 = path.supportsIPv4
        self.supportsIPv6 = path.supportsIPv6
        self.supportsDNS = path.supportsDNS
        
        // 인터페이스 목록 생성
        self.interfaces = path.availableInterfaces.map { interface in
            NetworkInterfaceInfo(
                id: interface.name,
                name: interface.name,
                type: NetworkConnectionType.from(interface.type),
                isExpensive: path.isExpensive,
                isConstrained: path.isConstrained
            )
        }
    }
    
    /// 직접 생성
    init(status: PathStatus, connectionType: NetworkConnectionType, isExpensive: Bool,
         isConstrained: Bool, supportsIPv4: Bool, supportsIPv6: Bool, supportsDNS: Bool,
         interfaces: [NetworkInterfaceInfo]) {
        self.status = status
        self.connectionType = connectionType
        self.isExpensive = isExpensive
        self.isConstrained = isConstrained
        self.supportsIPv4 = supportsIPv4
        self.supportsIPv6 = supportsIPv6
        self.supportsDNS = supportsDNS
        self.interfaces = interfaces
    }
}

// MARK: - 경로 상태 열거형
/// NWPath.Status를 추상화
enum PathStatus: String {
    case satisfied = "연결됨"
    case unsatisfied = "연결 안 됨"
    case requiresConnection = "연결 필요"
    
    var iconName: String {
        switch self {
        case .satisfied: return "checkmark.circle.fill"
        case .unsatisfied: return "xmark.circle.fill"
        case .requiresConnection: return "exclamationmark.circle"
        }
    }
    
    var colorName: String {
        switch self {
        case .satisfied: return "green"
        case .unsatisfied: return "red"
        case .requiresConnection: return "orange"
        }
    }
}

// MARK: - 연결 정보
/// 활성 연결에 대한 상세 정보
struct ConnectionInfo: Identifiable {
    let id: UUID
    let host: String
    let port: UInt16
    let `protocol`: ConnectionProtocol
    var state: ConnectionState
    let createdAt: Date
    var lastActivityAt: Date
    
    init(host: String, port: UInt16, protocol: ConnectionProtocol) {
        self.id = UUID()
        self.host = host
        self.port = port
        self.protocol = `protocol`
        self.state = .idle
        self.createdAt = Date()
        self.lastActivityAt = Date()
    }
    
    /// 연결 대상 문자열
    var endpoint: String {
        "\(host):\(port)"
    }
    
    /// 연결 지속 시간
    var duration: TimeInterval {
        Date().timeIntervalSince(createdAt)
    }
    
    /// 포맷된 연결 시간
    var formattedDuration: String {
        let seconds = Int(duration)
        let minutes = seconds / 60
        let hours = minutes / 60
        
        if hours > 0 {
            return "\(hours)시간 \(minutes % 60)분"
        } else if minutes > 0 {
            return "\(minutes)분 \(seconds % 60)초"
        } else {
            return "\(seconds)초"
        }
    }
}
