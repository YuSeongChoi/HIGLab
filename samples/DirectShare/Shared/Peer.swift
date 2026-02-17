// Peer.swift
// DirectShare - Wi-Fi Aware 직접 파일 공유
// 발견된 피어(기기) 모델

import Foundation
import Network

/// 피어 연결 상태
enum PeerConnectionState: String, Sendable {
    case discovered = "발견됨"
    case connecting = "연결중"
    case connected = "연결됨"
    case disconnected = "연결 해제"
    case failed = "연결 실패"
    
    /// 연결 가능 여부
    var canConnect: Bool {
        self == .discovered || self == .disconnected || self == .failed
    }
    
    /// 연결되어 있는지 여부
    var isConnected: Bool {
        self == .connected
    }
    
    /// 상태 아이콘
    var icon: String {
        switch self {
        case .discovered: return "wifi"
        case .connecting: return "wifi.exclamationmark"
        case .connected: return "wifi.circle.fill"
        case .disconnected: return "wifi.slash"
        case .failed: return "xmark.circle"
        }
    }
}

/// Wi-Fi Aware로 발견된 피어 정보
@Observable
final class Peer: Identifiable, Sendable {
    let id: UUID
    let deviceName: String
    let endpoint: NWEndpoint
    let discoveredAt: Date
    
    // 메타데이터 (TXT 레코드에서 추출)
    let deviceModel: String?
    let osVersion: String?
    let appVersion: String?
    
    // 연결 상태
    nonisolated(unsafe) var connectionState: PeerConnectionState
    nonisolated(unsafe) var lastSeen: Date
    nonisolated(unsafe) var signalStrength: Int? // -100 ~ 0 dBm
    
    // 활성 연결 (있는 경우)
    nonisolated(unsafe) var activeConnection: NWConnection?
    
    /// 신호 강도 레벨 (0~4)
    var signalLevel: Int {
        guard let strength = signalStrength else { return 0 }
        switch strength {
        case -50...0: return 4    // 매우 강함
        case -65..<(-50): return 3  // 강함
        case -75..<(-65): return 2  // 보통
        case -85..<(-75): return 1  // 약함
        default: return 0           // 매우 약함
        }
    }
    
    /// 신호 강도 아이콘
    var signalIcon: String {
        switch signalLevel {
        case 4: return "wifi"
        case 3: return "wifi"
        case 2: return "wifi"
        case 1: return "wifi.exclamationmark"
        default: return "wifi.slash"
        }
    }
    
    /// 마지막으로 본 시간 (상대적)
    var lastSeenRelative: String {
        let interval = Date().timeIntervalSince(lastSeen)
        if interval < 5 {
            return "방금 전"
        } else if interval < 60 {
            return "\(Int(interval))초 전"
        } else if interval < 3600 {
            return "\(Int(interval / 60))분 전"
        } else {
            return "\(Int(interval / 3600))시간 전"
        }
    }
    
    init(
        id: UUID = UUID(),
        deviceName: String,
        endpoint: NWEndpoint,
        deviceModel: String? = nil,
        osVersion: String? = nil,
        appVersion: String? = nil,
        signalStrength: Int? = nil
    ) {
        self.id = id
        self.deviceName = deviceName
        self.endpoint = endpoint
        self.discoveredAt = Date()
        self.deviceModel = deviceModel
        self.osVersion = osVersion
        self.appVersion = appVersion
        self.connectionState = .discovered
        self.lastSeen = Date()
        self.signalStrength = signalStrength
        self.activeConnection = nil
    }
    
    /// TXT 레코드에서 피어 생성
    static func from(
        endpoint: NWEndpoint,
        txtRecord: [String: String]
    ) -> Peer {
        let deviceName = txtRecord["name"] ?? "알 수 없는 기기"
        let deviceModel = txtRecord["model"]
        let osVersion = txtRecord["os"]
        let appVersion = txtRecord["app"]
        
        return Peer(
            deviceName: deviceName,
            endpoint: endpoint,
            deviceModel: deviceModel,
            osVersion: osVersion,
            appVersion: appVersion
        )
    }
    
    /// 피어 정보 업데이트
    func update(lastSeen: Date = Date(), signalStrength: Int? = nil) {
        self.lastSeen = lastSeen
        if let strength = signalStrength {
            self.signalStrength = strength
        }
    }
}

// MARK: - Hashable

extension Peer: Hashable {
    static func == (lhs: Peer, rhs: Peer) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - 디버그용 설명

extension Peer: CustomStringConvertible {
    var description: String {
        """
        Peer: \(deviceName)
        - ID: \(id.uuidString.prefix(8))...
        - State: \(connectionState.rawValue)
        - Model: \(deviceModel ?? "N/A")
        - Signal: \(signalStrength.map { "\($0) dBm" } ?? "N/A")
        - Last seen: \(lastSeenRelative)
        """
    }
}
