//
//  AccessoryCategory.swift
//  DevicePair
//
//  액세서리 카테고리 정의 - 다양한 액세서리 유형을 분류
//

import SwiftUI

// MARK: - 액세서리 카테고리

/// 액세서리의 유형을 나타내는 열거형
/// AccessorySetupKit에서 지원하는 다양한 기기 유형을 정의
enum AccessoryCategory: String, CaseIterable, Identifiable {
    case speaker = "스피커"
    case headphones = "헤드폰"
    case light = "조명"
    case sensor = "센서"
    case camera = "카메라"
    case lock = "잠금장치"
    case thermostat = "온도조절기"
    case outlet = "스마트 콘센트"
    case other = "기타"
    
    var id: String { rawValue }
    
    // MARK: - 아이콘
    
    /// 카테고리에 해당하는 SF Symbol 아이콘 이름
    var iconName: String {
        switch self {
        case .speaker: return "hifispeaker.fill"
        case .headphones: return "headphones"
        case .light: return "lightbulb.fill"
        case .sensor: return "sensor.fill"
        case .camera: return "camera.fill"
        case .lock: return "lock.fill"
        case .thermostat: return "thermometer.medium"
        case .outlet: return "poweroutlet.type.b.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
    
    // MARK: - 색상
    
    /// 카테고리를 대표하는 색상
    var color: Color {
        switch self {
        case .speaker: return .purple
        case .headphones: return .blue
        case .light: return .yellow
        case .sensor: return .green
        case .camera: return .red
        case .lock: return .orange
        case .thermostat: return .cyan
        case .outlet: return .gray
        case .other: return .secondary
        }
    }
    
    // MARK: - 설명
    
    /// 카테고리에 대한 간단한 설명
    var description: String {
        switch self {
        case .speaker:
            return "블루투스 스피커, 사운드바 등 오디오 출력 장치"
        case .headphones:
            return "무선 이어폰, 헤드셋 등 개인 오디오 장치"
        case .light:
            return "스마트 전구, LED 조명 등 조명 장치"
        case .sensor:
            return "온도, 습도, 동작 감지 등 각종 센서"
        case .camera:
            return "보안 카메라, 웹캠 등 영상 장치"
        case .lock:
            return "스마트 도어락, 잠금장치"
        case .thermostat:
            return "스마트 온도조절기, 에어컨 컨트롤러"
        case .outlet:
            return "스마트 플러그, 멀티탭 등 전원 제어 장치"
        case .other:
            return "기타 스마트 액세서리"
        }
    }
    
    // MARK: - 검색 키워드
    
    /// 액세서리 검색 시 사용할 블루투스 서비스 UUID (예시)
    /// 실제 구현 시에는 제조사별 실제 UUID 사용
    var bluetoothServiceUUIDs: [String] {
        switch self {
        case .speaker:
            return ["0000110B-0000-1000-8000-00805F9B34FB"] // A2DP Sink
        case .headphones:
            return ["0000110B-0000-1000-8000-00805F9B34FB", "0000111E-0000-1000-8000-00805F9B34FB"]
        case .light:
            return ["0000FE0F-0000-1000-8000-00805F9B34FB"]
        case .sensor:
            return ["0000181A-0000-1000-8000-00805F9B34FB"] // Environmental Sensing
        case .camera:
            return ["0000FE0D-0000-1000-8000-00805F9B34FB"]
        case .lock:
            return ["0000FE0E-0000-1000-8000-00805F9B34FB"]
        case .thermostat:
            return ["0000181A-0000-1000-8000-00805F9B34FB"]
        case .outlet:
            return ["0000FE0C-0000-1000-8000-00805F9B34FB"]
        case .other:
            return []
        }
    }
}

// MARK: - 카테고리 그룹

/// 관련 카테고리를 그룹화
enum CategoryGroup: String, CaseIterable {
    case audio = "오디오"
    case lighting = "조명"
    case security = "보안"
    case climate = "환경"
    case power = "전원"
    case other = "기타"
    
    /// 그룹에 속하는 카테고리들
    var categories: [AccessoryCategory] {
        switch self {
        case .audio:
            return [.speaker, .headphones]
        case .lighting:
            return [.light]
        case .security:
            return [.camera, .lock]
        case .climate:
            return [.sensor, .thermostat]
        case .power:
            return [.outlet]
        case .other:
            return [.other]
        }
    }
    
    /// 그룹 아이콘
    var iconName: String {
        switch self {
        case .audio: return "speaker.wave.3.fill"
        case .lighting: return "lightbulb.led.fill"
        case .security: return "shield.fill"
        case .climate: return "cloud.sun.fill"
        case .power: return "bolt.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}
