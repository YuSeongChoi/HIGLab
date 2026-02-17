// ConnectionState.swift
// DirectShare - Wi-Fi Aware 직접 파일 공유
// 연결 상태 및 메시지 프로토콜 정의

import Foundation

/// 전체 앱의 연결 상태
enum AppConnectionState: Sendable {
    case idle                    // 대기 중
    case scanning                // 피어 검색 중
    case advertising             // 서비스 광고 중
    case scanningAndAdvertising  // 검색 + 광고 동시
    case connecting(Peer)        // 특정 피어에 연결 중
    case connected(Peer)         // 연결됨
    case transferring(Peer, TransferFile)  // 파일 전송 중
    case error(ConnectionError)  // 오류 발생
    
    /// 상태 설명
    var description: String {
        switch self {
        case .idle:
            return "대기 중"
        case .scanning:
            return "주변 기기 검색 중..."
        case .advertising:
            return "서비스 광고 중..."
        case .scanningAndAdvertising:
            return "검색 및 광고 중..."
        case .connecting(let peer):
            return "\(peer.deviceName)에 연결 중..."
        case .connected(let peer):
            return "\(peer.deviceName)과 연결됨"
        case .transferring(let peer, let file):
            return "\(peer.deviceName)로 \(file.fileName) 전송 중"
        case .error(let error):
            return error.localizedDescription
        }
    }
    
    /// 활성 상태인지 여부
    var isActive: Bool {
        switch self {
        case .idle:
            return false
        default:
            return true
        }
    }
}

/// 연결 관련 오류
enum ConnectionError: Error, LocalizedError, Sendable {
    case wifiAwareUnavailable
    case permissionDenied
    case peerNotFound
    case connectionFailed(String)
    case connectionLost
    case transferFailed(String)
    case timeout
    case cancelled
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .wifiAwareUnavailable:
            return "Wi-Fi Aware를 사용할 수 없습니다"
        case .permissionDenied:
            return "권한이 거부되었습니다"
        case .peerNotFound:
            return "피어를 찾을 수 없습니다"
        case .connectionFailed(let reason):
            return "연결 실패: \(reason)"
        case .connectionLost:
            return "연결이 끊어졌습니다"
        case .transferFailed(let reason):
            return "전송 실패: \(reason)"
        case .timeout:
            return "연결 시간 초과"
        case .cancelled:
            return "작업이 취소되었습니다"
        case .unknown(let message):
            return "알 수 없는 오류: \(message)"
        }
    }
}

/// 피어 간 통신 메시지 타입
enum MessageType: UInt8, Codable, Sendable {
    case hello = 1              // 연결 초기 핸드셰이크
    case helloAck = 2           // 핸드셰이크 응답
    case fileOffer = 10         // 파일 전송 제안
    case fileAccept = 11        // 파일 수신 승인
    case fileReject = 12        // 파일 수신 거부
    case fileData = 13          // 파일 데이터 청크
    case fileComplete = 14      // 파일 전송 완료
    case fileCancel = 15        // 파일 전송 취소
    case ping = 20              // 연결 유지 확인
    case pong = 21              // 핑 응답
    case disconnect = 30        // 연결 종료
}

/// 피어 간 통신 메시지
struct PeerMessage: Codable, Sendable {
    let type: MessageType
    let payload: Data?
    let timestamp: Date
    let messageId: UUID
    
    init(type: MessageType, payload: Data? = nil) {
        self.type = type
        self.payload = payload
        self.timestamp = Date()
        self.messageId = UUID()
    }
    
    /// 메시지를 Data로 직렬화
    func serialize() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
    
    /// Data에서 메시지 역직렬화
    static func deserialize(from data: Data) throws -> PeerMessage {
        let decoder = JSONDecoder()
        return try decoder.decode(PeerMessage.self, from: data)
    }
}

/// 파일 전송 제안 메시지 페이로드
struct FileOfferPayload: Codable, Sendable {
    let metadata: TransferMetadata
    let senderName: String
    let totalFiles: Int  // 다중 파일 전송 시 전체 개수
    let currentIndex: Int  // 현재 파일 인덱스
}

/// 파일 데이터 청크
struct FileChunk: Codable, Sendable {
    let fileId: UUID
    let chunkIndex: Int
    let totalChunks: Int
    let data: Data
    let offset: Int64
    let isLast: Bool
    
    /// 청크 크기 (64KB)
    static let chunkSize: Int = 64 * 1024
}

/// 연결 상태 변경 이벤트
struct ConnectionEvent: Sendable {
    let peer: Peer
    let oldState: PeerConnectionState
    let newState: PeerConnectionState
    let timestamp: Date
    let error: ConnectionError?
    
    init(
        peer: Peer,
        oldState: PeerConnectionState,
        newState: PeerConnectionState,
        error: ConnectionError? = nil
    ) {
        self.peer = peer
        self.oldState = oldState
        self.newState = newState
        self.timestamp = Date()
        self.error = error
    }
}
