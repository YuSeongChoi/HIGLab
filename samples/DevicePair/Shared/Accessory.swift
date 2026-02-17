//
//  Accessory.swift
//  DevicePair
//
//  액세서리 모델 - 페어링된 기기 정보를 담는 핵심 데이터 구조
//

import Foundation
import AccessorySetupKit

// MARK: - 액세서리 모델

/// 페어링된 액세서리의 정보를 표현하는 모델
/// AccessorySetupKit의 ASAccessory를 래핑하여 앱에서 사용하기 쉽게 추상화
struct Accessory: Identifiable, Hashable {
    
    // MARK: - 프로퍼티
    
    /// 고유 식별자
    let id: UUID
    
    /// 액세서리 이름 (예: "거실 스피커", "침실 조명")
    var name: String
    
    /// 액세서리 카테고리
    let category: AccessoryCategory
    
    /// 연결 상태
    var connectionState: ConnectionState
    
    /// 배터리 잔량 (0-100, nil이면 배터리 정보 없음)
    var batteryLevel: Int?
    
    /// 펌웨어 버전
    var firmwareVersion: String?
    
    /// 마지막 연결 시간
    var lastConnected: Date?
    
    /// 제조사
    let manufacturer: String
    
    /// 모델 번호
    let modelNumber: String
    
    /// 일련 번호
    let serialNumber: String?
    
    /// 사용자 정의 설정
    var settings: AccessorySettings
    
    // MARK: - 초기화
    
    init(
        id: UUID = UUID(),
        name: String,
        category: AccessoryCategory,
        connectionState: ConnectionState = .disconnected,
        batteryLevel: Int? = nil,
        firmwareVersion: String? = nil,
        lastConnected: Date? = nil,
        manufacturer: String,
        modelNumber: String,
        serialNumber: String? = nil,
        settings: AccessorySettings = AccessorySettings()
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.connectionState = connectionState
        self.batteryLevel = batteryLevel
        self.firmwareVersion = firmwareVersion
        self.lastConnected = lastConnected
        self.manufacturer = manufacturer
        self.modelNumber = modelNumber
        self.serialNumber = serialNumber
        self.settings = settings
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Accessory, rhs: Accessory) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 연결 상태

/// 액세서리의 현재 연결 상태
enum ConnectionState: String, CaseIterable {
    case connected = "연결됨"
    case connecting = "연결 중"
    case disconnected = "연결 안 됨"
    case failed = "연결 실패"
    
    /// 상태에 따른 SF Symbol 아이콘
    var iconName: String {
        switch self {
        case .connected: return "checkmark.circle.fill"
        case .connecting: return "arrow.triangle.2.circlepath"
        case .disconnected: return "circle.dashed"
        case .failed: return "exclamationmark.triangle.fill"
        }
    }
    
    /// 상태에 따른 색상 이름
    var colorName: String {
        switch self {
        case .connected: return "green"
        case .connecting: return "orange"
        case .disconnected: return "gray"
        case .failed: return "red"
        }
    }
}

// MARK: - 액세서리 설정

/// 개별 액세서리의 사용자 정의 설정
struct AccessorySettings: Hashable {
    /// 알림 활성화 여부
    var notificationsEnabled: Bool = true
    
    /// 자동 연결 활성화 여부
    var autoConnectEnabled: Bool = true
    
    /// 저전력 모드 사용 여부
    var lowPowerModeEnabled: Bool = false
    
    /// 사용자 지정 색상 (16진수 문자열)
    var customColor: String?
    
    /// 사용자 지정 아이콘
    var customIcon: String?
    
    /// 위치/방 이름
    var roomName: String?
    
    /// 우선순위 (낮을수록 높은 우선순위)
    var priority: Int = 0
}

// MARK: - 미리보기용 샘플 데이터

extension Accessory {
    /// 미리보기 및 테스트용 샘플 데이터
    static let sampleAccessories: [Accessory] = [
        Accessory(
            name: "거실 스피커",
            category: .speaker,
            connectionState: .connected,
            batteryLevel: nil,
            firmwareVersion: "2.1.0",
            lastConnected: Date(),
            manufacturer: "SoundMax",
            modelNumber: "SM-100",
            serialNumber: "SM100-2024-001",
            settings: AccessorySettings(roomName: "거실")
        ),
        Accessory(
            name: "침실 조명",
            category: .light,
            connectionState: .connected,
            batteryLevel: nil,
            firmwareVersion: "1.5.2",
            lastConnected: Date().addingTimeInterval(-3600),
            manufacturer: "BrightHome",
            modelNumber: "BH-LED-01",
            serialNumber: "BH001-2024-042",
            settings: AccessorySettings(roomName: "침실", customColor: "#FFD700")
        ),
        Accessory(
            name: "무선 이어폰",
            category: .headphones,
            connectionState: .disconnected,
            batteryLevel: 45,
            firmwareVersion: "3.0.1",
            lastConnected: Date().addingTimeInterval(-86400),
            manufacturer: "AudioPro",
            modelNumber: "AP-BT-200",
            serialNumber: "AP200-2024-789"
        ),
        Accessory(
            name: "스마트 온도계",
            category: .sensor,
            connectionState: .connected,
            batteryLevel: 78,
            firmwareVersion: "1.2.0",
            lastConnected: Date(),
            manufacturer: "TempSense",
            modelNumber: "TS-MINI",
            serialNumber: nil,
            settings: AccessorySettings(roomName: "주방", lowPowerModeEnabled: true)
        )
    ]
}
