//
//  DiscoveredDevice.swift
//  BLEScanner
//
//  BLE 스캔 중 발견된 기기를 나타내는 모델
//

import Foundation
import CoreBluetooth

/// 발견된 BLE 기기 모델
/// - Identifiable: SwiftUI 리스트에서 사용
/// - ObservableObject: 상태 변화 감지 (RSSI 업데이트 등)
final class DiscoveredDevice: Identifiable, ObservableObject {
    
    // MARK: - 식별자
    
    /// 고유 식별자 (peripheral UUID 사용)
    let id: UUID
    
    /// CoreBluetooth peripheral 객체
    let peripheral: CBPeripheral
    
    // MARK: - 기기 정보
    
    /// 기기 이름 (광고 데이터 또는 peripheral 이름)
    @Published var name: String
    
    /// 신호 강도 (dBm)
    /// - -30 ~ -50: 매우 강함
    /// - -50 ~ -70: 양호
    /// - -70 ~ -90: 약함
    /// - -90 이하: 매우 약함
    @Published var rssi: Int
    
    /// 광고 데이터
    let advertisementData: [String: Any]
    
    /// 마지막 발견 시간
    @Published var lastSeen: Date
    
    /// 연결 가능 여부
    let isConnectable: Bool
    
    // MARK: - 연결 상태
    
    /// 현재 연결 상태
    @Published var connectionState: ConnectionState = .disconnected
    
    /// 연결 상태 열거형
    enum ConnectionState: String {
        case disconnected = "연결 끊김"
        case connecting = "연결 중..."
        case connected = "연결됨"
        case disconnecting = "연결 해제 중..."
    }
    
    // MARK: - 서비스 및 특성
    
    /// 발견된 서비스 목록
    @Published var services: [CBService] = []
    
    /// 서비스별 특성 딕셔너리
    @Published var characteristics: [CBUUID: [CBCharacteristic]] = [:]
    
    // MARK: - 초기화
    
    /// 발견된 기기 초기화
    /// - Parameters:
    ///   - peripheral: CoreBluetooth peripheral 객체
    ///   - rssi: 신호 강도
    ///   - advertisementData: 광고 데이터
    init(peripheral: CBPeripheral, rssi: Int, advertisementData: [String: Any]) {
        self.id = peripheral.identifier
        self.peripheral = peripheral
        self.rssi = rssi
        self.advertisementData = advertisementData
        self.lastSeen = Date()
        
        // 이름 추출: 광고 데이터 > peripheral 이름 > "알 수 없는 기기"
        if let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            self.name = localName
        } else {
            self.name = peripheral.name ?? "알 수 없는 기기"
        }
        
        // 연결 가능 여부 확인
        if let connectable = advertisementData[CBAdvertisementDataIsConnectable] as? Bool {
            self.isConnectable = connectable
        } else {
            self.isConnectable = true
        }
    }
    
    // MARK: - 공개 메서드
    
    /// RSSI 및 발견 시간 업데이트
    /// - Parameter newRSSI: 새로운 RSSI 값
    func updateRSSI(_ newRSSI: Int) {
        self.rssi = newRSSI
        self.lastSeen = Date()
    }
    
    /// 신호 강도 레벨 (UI 표시용)
    var signalStrength: SignalStrength {
        switch rssi {
        case -50...0:
            return .excellent
        case -70..<(-50):
            return .good
        case -85..<(-70):
            return .fair
        default:
            return .weak
        }
    }
    
    /// 신호 강도 열거형
    enum SignalStrength: String {
        case excellent = "매우 강함"
        case good = "양호"
        case fair = "보통"
        case weak = "약함"
        
        /// SF Symbol 이름
        var symbolName: String {
            switch self {
            case .excellent: return "wifi"
            case .good: return "wifi"
            case .fair: return "wifi.exclamationmark"
            case .weak: return "wifi.slash"
            }
        }
        
        /// 색상
        var color: String {
            switch self {
            case .excellent: return "green"
            case .good: return "blue"
            case .fair: return "orange"
            case .weak: return "red"
            }
        }
    }
    
    /// 광고 중인 서비스 UUID 목록
    var advertisedServiceUUIDs: [CBUUID] {
        advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] ?? []
    }
    
    /// 제조사 데이터 (있는 경우)
    var manufacturerData: Data? {
        advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
    }
    
    /// 송신 전력 (dBm, 있는 경우)
    var txPowerLevel: Int? {
        advertisementData[CBAdvertisementDataTxPowerLevelKey] as? Int
    }
}

// MARK: - Equatable

extension DiscoveredDevice: Equatable {
    static func == (lhs: DiscoveredDevice, rhs: DiscoveredDevice) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Hashable

extension DiscoveredDevice: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
