// PermissionStatus.swift
// PermissionHub - iOS 26 PermissionKit 샘플
// 권한 상태 모델 정의

import Foundation
import PermissionKit

// MARK: - 권한 상태 열거형
/// 권한의 현재 상태를 나타냅니다
/// iOS 26 PermissionKit의 AuthorizationStatus와 매핑됩니다
public enum PermissionStatus: String, Sendable, Equatable {
    /// 아직 사용자에게 권한을 요청하지 않은 상태
    case notDetermined = "notDetermined"
    
    /// 권한이 허용된 상태
    case authorized = "authorized"
    
    /// 권한이 거부된 상태
    case denied = "denied"
    
    /// 시스템 설정에서 제한된 상태 (자녀 보호 등)
    case restricted = "restricted"
    
    /// 제한적으로 허용된 상태 (예: 선택한 사진만)
    case limited = "limited"
    
    /// 일시적으로 허용된 상태 (위치 권한의 "한 번만 허용")
    case provisional = "provisional"
    
    /// 해당 기기에서 지원하지 않는 권한
    case unsupported = "unsupported"
    
    // MARK: - PermissionKit 상태 변환
    /// iOS 26 PermissionKit의 AuthorizationStatus에서 변환
    public init(from authorizationStatus: AuthorizationStatus) {
        switch authorizationStatus {
        case .notDetermined:
            self = .notDetermined
        case .authorized:
            self = .authorized
        case .denied:
            self = .denied
        case .restricted:
            self = .restricted
        case .limited:
            self = .limited
        case .provisional:
            self = .provisional
        @unknown default:
            self = .notDetermined
        }
    }
    
    // MARK: - 상태 표시
    /// 사용자에게 보여줄 상태 텍스트
    public var displayText: String {
        switch self {
        case .notDetermined:
            return "요청 전"
        case .authorized:
            return "허용됨"
        case .denied:
            return "거부됨"
        case .restricted:
            return "제한됨"
        case .limited:
            return "제한적 허용"
        case .provisional:
            return "임시 허용"
        case .unsupported:
            return "지원 안 됨"
        }
    }
    
    /// 상태를 나타내는 SF Symbol 아이콘
    public var iconName: String {
        switch self {
        case .notDetermined:
            return "questionmark.circle.fill"
        case .authorized:
            return "checkmark.circle.fill"
        case .denied:
            return "xmark.circle.fill"
        case .restricted:
            return "lock.circle.fill"
        case .limited:
            return "circle.lefthalf.filled"
        case .provisional:
            return "clock.circle.fill"
        case .unsupported:
            return "exclamationmark.triangle.fill"
        }
    }
    
    /// 상태별 색상 (SwiftUI Color 이름)
    public var colorName: String {
        switch self {
        case .notDetermined:
            return "secondary"
        case .authorized:
            return "green"
        case .denied:
            return "red"
        case .restricted:
            return "orange"
        case .limited:
            return "yellow"
        case .provisional:
            return "blue"
        case .unsupported:
            return "gray"
        }
    }
    
    // MARK: - 상태 판단
    /// 권한 요청이 가능한 상태인지 확인
    public var canRequest: Bool {
        self == .notDetermined
    }
    
    /// 권한이 허용된 상태인지 확인 (authorized, limited, provisional 포함)
    public var isGranted: Bool {
        switch self {
        case .authorized, .limited, .provisional:
            return true
        default:
            return false
        }
    }
    
    /// 설정 앱으로 안내해야 하는 상태인지 확인
    public var requiresSettings: Bool {
        switch self {
        case .denied, .restricted:
            return true
        default:
            return false
        }
    }
    
    /// 상태에 대한 상세 설명
    public var detailedDescription: String {
        switch self {
        case .notDetermined:
            return "이 권한은 아직 요청되지 않았습니다. 아래 버튼을 눌러 권한을 요청하세요."
        case .authorized:
            return "이 권한이 허용되었습니다. 모든 관련 기능을 사용할 수 있습니다."
        case .denied:
            return "이 권한이 거부되었습니다. 설정 앱에서 권한을 변경할 수 있습니다."
        case .restricted:
            return "이 권한은 시스템에서 제한되어 있습니다. 자녀 보호 기능이나 기기 관리 정책에 의해 제한될 수 있습니다."
        case .limited:
            return "제한적으로 허용되었습니다. 일부 항목에만 접근할 수 있습니다."
        case .provisional:
            return "임시로 허용되었습니다. 다음 사용 시 다시 확인이 필요할 수 있습니다."
        case .unsupported:
            return "이 기기에서는 해당 권한을 지원하지 않습니다."
        }
    }
}

// MARK: - 권한 정보 모델
/// 권한 타입과 상태를 함께 저장하는 모델
public struct PermissionInfo: Identifiable, Sendable, Equatable {
    /// 고유 식별자
    public let id: String
    
    /// 권한 타입
    public let type: PermissionType
    
    /// 현재 권한 상태
    public var status: PermissionStatus
    
    /// 마지막으로 상태를 확인한 시간
    public var lastChecked: Date
    
    /// 권한이 변경된 횟수 (디버깅용)
    public var changeCount: Int
    
    // MARK: - 초기화
    public init(
        type: PermissionType,
        status: PermissionStatus = .notDetermined,
        lastChecked: Date = Date(),
        changeCount: Int = 0
    ) {
        self.id = type.rawValue
        self.type = type
        self.status = status
        self.lastChecked = lastChecked
        self.changeCount = changeCount
    }
    
    // MARK: - 편의 프로퍼티
    /// 표시 이름 (타입에서 가져옴)
    public var displayName: String {
        type.displayName
    }
    
    /// 아이콘 이름 (타입에서 가져옴)
    public var iconName: String {
        type.iconName
    }
    
    /// 사용 설명 (타입에서 가져옴)
    public var usageDescription: String {
        type.usageDescription
    }
    
    /// 필수 권한 여부
    public var isEssential: Bool {
        type.isEssential
    }
}

// MARK: - 권한 상태 스냅샷
/// 특정 시점의 전체 권한 상태를 저장하는 구조체
public struct PermissionSnapshot: Sendable {
    /// 스냅샷 생성 시간
    public let timestamp: Date
    
    /// 모든 권한 정보
    public let permissions: [PermissionInfo]
    
    /// 앱 버전
    public let appVersion: String
    
    /// iOS 버전
    public let osVersion: String
    
    public init(
        permissions: [PermissionInfo],
        appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
        osVersion: String = ProcessInfo.processInfo.operatingSystemVersionString
    ) {
        self.timestamp = Date()
        self.permissions = permissions
        self.appVersion = appVersion
        self.osVersion = osVersion
    }
    
    // MARK: - 통계
    /// 허용된 권한 수
    public var grantedCount: Int {
        permissions.filter { $0.status.isGranted }.count
    }
    
    /// 거부된 권한 수
    public var deniedCount: Int {
        permissions.filter { $0.status == .denied }.count
    }
    
    /// 아직 요청하지 않은 권한 수
    public var notDeterminedCount: Int {
        permissions.filter { $0.status == .notDetermined }.count
    }
    
    /// 전체 권한 수
    public var totalCount: Int {
        permissions.count
    }
    
    /// 허용률 (0.0 ~ 1.0)
    public var grantedRatio: Double {
        guard totalCount > 0 else { return 0 }
        return Double(grantedCount) / Double(totalCount)
    }
}

// MARK: - 권한 변경 이벤트
/// 권한 상태 변경을 추적하기 위한 이벤트 모델
public struct PermissionChangeEvent: Sendable, Identifiable {
    public let id: UUID
    public let permissionType: PermissionType
    public let previousStatus: PermissionStatus
    public let newStatus: PermissionStatus
    public let timestamp: Date
    public let source: ChangeSource
    
    /// 변경이 발생한 소스
    public enum ChangeSource: String, Sendable {
        case appRequest = "앱 요청"
        case systemSettings = "설정 앱"
        case systemPolicy = "시스템 정책"
        case unknown = "알 수 없음"
    }
    
    public init(
        permissionType: PermissionType,
        previousStatus: PermissionStatus,
        newStatus: PermissionStatus,
        source: ChangeSource = .unknown
    ) {
        self.id = UUID()
        self.permissionType = permissionType
        self.previousStatus = previousStatus
        self.newStatus = newStatus
        self.timestamp = Date()
        self.source = source
    }
    
    /// 변경 내용을 설명하는 문자열
    public var changeDescription: String {
        "\(permissionType.displayName): \(previousStatus.displayText) → \(newStatus.displayText)"
    }
}
