//
//  PairingState.swift
//  DevicePair
//
//  페어링 상태 관리 - 액세서리 페어링 프로세스의 다양한 상태 정의
//

import Foundation

// MARK: - 페어링 상태

/// 액세서리 페어링 프로세스의 현재 상태
enum PairingState: Equatable {
    /// 대기 중 - 페어링 시작 전
    case idle
    
    /// 검색 중 - 주변 액세서리를 스캔하는 중
    case discovering
    
    /// 발견됨 - 페어링 가능한 액세서리 발견
    case discovered(count: Int)
    
    /// 페어링 중 - 선택한 액세서리와 페어링 진행 중
    case pairing(accessoryName: String)
    
    /// 인증 중 - 사용자 인증 또는 PIN 입력 대기
    case authenticating
    
    /// 설정 중 - 페어링 완료 후 초기 설정 진행
    case configuring
    
    /// 완료 - 페어링 성공
    case completed(accessoryName: String)
    
    /// 실패 - 페어링 중 오류 발생
    case failed(error: PairingError)
    
    /// 취소됨 - 사용자가 페어링 취소
    case cancelled
    
    // MARK: - 상태 정보
    
    /// 현재 상태에 대한 사용자 친화적 설명
    var description: String {
        switch self {
        case .idle:
            return "새로운 액세서리를 검색하려면 시작 버튼을 누르세요"
        case .discovering:
            return "주변에서 액세서리를 찾는 중..."
        case .discovered(let count):
            return "\(count)개의 액세서리를 발견했습니다"
        case .pairing(let name):
            return "'\(name)'과(와) 페어링하는 중..."
        case .authenticating:
            return "인증을 기다리는 중..."
        case .configuring:
            return "액세서리를 설정하는 중..."
        case .completed(let name):
            return "'\(name)' 페어링이 완료되었습니다!"
        case .failed(let error):
            return "페어링 실패: \(error.localizedDescription)"
        case .cancelled:
            return "페어링이 취소되었습니다"
        }
    }
    
    /// 진행 중인 상태인지 여부
    var isInProgress: Bool {
        switch self {
        case .discovering, .pairing, .authenticating, .configuring:
            return true
        default:
            return false
        }
    }
    
    /// 완료 상태인지 여부 (성공 또는 실패)
    var isTerminal: Bool {
        switch self {
        case .completed, .failed, .cancelled:
            return true
        default:
            return false
        }
    }
    
    /// 상태에 따른 SF Symbol 아이콘
    var iconName: String {
        switch self {
        case .idle:
            return "plus.circle"
        case .discovering:
            return "antenna.radiowaves.left.and.right"
        case .discovered:
            return "checkmark.circle"
        case .pairing:
            return "link"
        case .authenticating:
            return "key.fill"
        case .configuring:
            return "gearshape"
        case .completed:
            return "checkmark.seal.fill"
        case .failed:
            return "xmark.circle.fill"
        case .cancelled:
            return "xmark"
        }
    }
    
    /// 진행률 (0.0 ~ 1.0)
    var progress: Double {
        switch self {
        case .idle: return 0.0
        case .discovering: return 0.2
        case .discovered: return 0.3
        case .pairing: return 0.5
        case .authenticating: return 0.7
        case .configuring: return 0.9
        case .completed: return 1.0
        case .failed, .cancelled: return 0.0
        }
    }
}

// MARK: - 페어링 에러

/// 페어링 중 발생할 수 있는 오류 유형
enum PairingError: Error, Equatable {
    /// 블루투스가 꺼져 있음
    case bluetoothDisabled
    
    /// 블루투스 권한 없음
    case bluetoothPermissionDenied
    
    /// 액세서리를 찾을 수 없음
    case accessoryNotFound
    
    /// 연결 시간 초과
    case connectionTimeout
    
    /// 인증 실패
    case authenticationFailed
    
    /// 이미 페어링된 기기
    case alreadyPaired
    
    /// 호환되지 않는 기기
    case incompatibleDevice
    
    /// 네트워크 오류
    case networkError
    
    /// 알 수 없는 오류
    case unknown(message: String)
    
    // MARK: - LocalizedError
    
    var localizedDescription: String {
        switch self {
        case .bluetoothDisabled:
            return "블루투스가 꺼져 있습니다. 설정에서 블루투스를 켜주세요."
        case .bluetoothPermissionDenied:
            return "블루투스 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요."
        case .accessoryNotFound:
            return "액세서리를 찾을 수 없습니다. 기기가 켜져 있고 가까이 있는지 확인하세요."
        case .connectionTimeout:
            return "연결 시간이 초과되었습니다. 다시 시도해주세요."
        case .authenticationFailed:
            return "인증에 실패했습니다. PIN을 확인하고 다시 시도하세요."
        case .alreadyPaired:
            return "이미 페어링된 기기입니다."
        case .incompatibleDevice:
            return "이 앱과 호환되지 않는 기기입니다."
        case .networkError:
            return "네트워크 오류가 발생했습니다. 연결 상태를 확인하세요."
        case .unknown(let message):
            return "알 수 없는 오류: \(message)"
        }
    }
    
    /// 오류 복구 제안
    var recoverySuggestion: String? {
        switch self {
        case .bluetoothDisabled:
            return "설정 > 블루투스에서 블루투스를 켜세요."
        case .bluetoothPermissionDenied:
            return "설정 > 개인 정보 보호 > 블루투스에서 이 앱에 대한 권한을 허용하세요."
        case .accessoryNotFound:
            return "액세서리의 전원을 확인하고, 페어링 모드로 설정한 후 다시 시도하세요."
        case .connectionTimeout:
            return "액세서리를 기기에 더 가까이 가져온 후 다시 시도하세요."
        case .authenticationFailed:
            return "액세서리 설명서에서 올바른 PIN을 확인하세요."
        case .alreadyPaired:
            return "기기 목록에서 해당 액세서리를 확인하세요."
        case .incompatibleDevice:
            return "지원되는 액세서리 목록을 확인하세요."
        case .networkError:
            return "Wi-Fi 또는 셀룰러 연결을 확인하세요."
        case .unknown:
            return "앱을 재시작하고 다시 시도하세요."
        }
    }
}

// MARK: - 검색된 액세서리

/// 검색 중 발견된 아직 페어링되지 않은 액세서리
struct DiscoveredAccessory: Identifiable {
    let id: UUID
    let name: String
    let category: AccessoryCategory
    let signalStrength: Int // RSSI 값
    let isReadyToPair: Bool
    
    /// 신호 강도를 사람이 읽기 쉬운 형태로 변환
    var signalStrengthDescription: String {
        switch signalStrength {
        case -50...0:
            return "매우 강함"
        case -60..<(-50):
            return "강함"
        case -70..<(-60):
            return "보통"
        case -80..<(-70):
            return "약함"
        default:
            return "매우 약함"
        }
    }
    
    /// 신호 강도 아이콘
    var signalIcon: String {
        switch signalStrength {
        case -50...0:
            return "wifi"
        case -60..<(-50):
            return "wifi"
        case -70..<(-60):
            return "wifi.exclamationmark"
        default:
            return "wifi.slash"
        }
    }
}
