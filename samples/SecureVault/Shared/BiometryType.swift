import Foundation
import LocalAuthentication
import SwiftUI

// MARK: - 생체 인증 유형
/// LABiometryType을 래핑하여 UI에서 사용하기 쉽게 만든 열거형
/// SwiftUI 뷰와의 통합 및 사용자 친화적 문자열 제공

/// 지원하는 생체 인증 유형
/// - Note: Apple의 모든 생체 인증 방식을 포함 (Face ID, Touch ID, Optic ID)
enum BiometryType: String, CaseIterable, Identifiable, Codable {
    /// Face ID (iPhone X 이후, iPad Pro 2018 이후)
    case faceID = "faceID"
    
    /// Touch ID (지문 인식)
    case touchID = "touchID"
    
    /// Optic ID (Apple Vision Pro)
    case opticID = "opticID"
    
    /// 생체 인증 없음
    case none = "none"
    
    // MARK: - Identifiable
    
    var id: String { rawValue }
    
    // MARK: - LABiometryType 변환
    
    /// LABiometryType으로부터 초기화
    /// - Parameter laBiometryType: LocalAuthentication 프레임워크의 생체 인증 유형
    init(from laBiometryType: LABiometryType) {
        switch laBiometryType {
        case .faceID:
            self = .faceID
        case .touchID:
            self = .touchID
        case .opticID:
            self = .opticID
        case .none:
            self = .none
        @unknown default:
            self = .none
        }
    }
    
    /// 현재 기기의 생체 인증 유형 감지
    /// - Note: LAContext를 생성하고 canEvaluatePolicy를 호출해야 biometryType이 설정됨
    static var current: BiometryType {
        let context = LAContext()
        var error: NSError?
        
        // canEvaluatePolicy 호출 후에야 biometryType에 값이 설정됨
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        return BiometryType(from: context.biometryType)
    }
    
    // MARK: - 표시 속성
    
    /// 사용자에게 표시할 이름
    var displayName: String {
        switch self {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .opticID:
            return "Optic ID"
        case .none:
            return "생체 인증 없음"
        }
    }
    
    /// 짧은 이름 (버튼 등에 사용)
    var shortName: String {
        switch self {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .opticID:
            return "Optic ID"
        case .none:
            return "암호"
        }
    }
    
    /// SF Symbols 아이콘 이름
    var iconName: String {
        switch self {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .opticID:
            return "opticid"
        case .none:
            return "lock.fill"
        }
    }
    
    /// 대체 아이콘 (구 버전 iOS 호환용)
    var fallbackIconName: String {
        switch self {
        case .faceID:
            return "face.smiling"
        case .touchID:
            return "hand.raised.fill"
        case .opticID:
            return "eye.fill"
        case .none:
            return "lock.fill"
        }
    }
    
    /// 생체 인증 활성화 안내 메시지
    var enablePrompt: String {
        switch self {
        case .faceID:
            return "Face ID를 사용하여 빠르고 안전하게 잠금을 해제할 수 있습니다"
        case .touchID:
            return "Touch ID를 사용하여 빠르고 안전하게 잠금을 해제할 수 있습니다"
        case .opticID:
            return "Optic ID를 사용하여 빠르고 안전하게 잠금을 해제할 수 있습니다"
        case .none:
            return "생체 인증을 사용할 수 없습니다. 암호를 사용합니다"
        }
    }
    
    /// 인증 요청 시 표시할 메시지
    var authenticationReason: String {
        switch self {
        case .faceID:
            return "Face ID로 인증"
        case .touchID:
            return "Touch ID로 인증"
        case .opticID:
            return "Optic ID로 인증"
        case .none:
            return "암호를 입력하세요"
        }
    }
    
    /// 설정 앱 내 경로 안내
    var settingsPath: String {
        switch self {
        case .faceID:
            return "설정 > Face ID 및 암호"
        case .touchID:
            return "설정 > Touch ID 및 암호"
        case .opticID:
            return "설정 > Optic ID 및 암호"
        case .none:
            return "설정 > 암호"
        }
    }
    
    // MARK: - 색상
    
    /// 기본 테마 색상
    var color: Color {
        switch self {
        case .faceID:
            return .blue
        case .touchID:
            return .pink
        case .opticID:
            return .purple
        case .none:
            return .gray
        }
    }
    
    /// 그라디언트 색상
    var gradient: LinearGradient {
        switch self {
        case .faceID:
            return LinearGradient(
                colors: [.blue, .cyan],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .touchID:
            return LinearGradient(
                colors: [.pink, .red],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .opticID:
            return LinearGradient(
                colors: [.purple, .indigo],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .none:
            return LinearGradient(
                colors: [.gray, .secondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    // MARK: - 가용성 확인
    
    /// 생체 인증이 사용 가능한지 여부
    var isAvailable: Bool {
        self != .none
    }
    
    /// 하드웨어가 Secure Enclave을 지원하는지 (근사치)
    /// - Note: 생체 인증이 있는 기기는 대부분 Secure Enclave 지원
    var supportsSecureEnclave: Bool {
        self != .none
    }
}

// MARK: - 생체 인증 상태
/// 생체 인증의 현재 상태를 나타내는 열거형
enum BiometricStatus: Equatable {
    /// 사용 가능
    case available(BiometryType)
    
    /// 하드웨어 미지원
    case notAvailable
    
    /// 생체 정보 미등록
    case notEnrolled(BiometryType)
    
    /// 잠금됨 (너무 많은 실패 시도)
    case lockedOut(BiometryType)
    
    /// 기기 암호 미설정
    case passcodeNotSet
    
    /// 권한 거부됨
    case denied
    
    // MARK: - 현재 상태 감지
    
    /// 현재 기기의 생체 인증 상태
    static var current: BiometricStatus {
        let context = LAContext()
        var error: NSError?
        
        let canEvaluate = context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        )
        
        let biometryType = BiometryType(from: context.biometryType)
        
        if canEvaluate {
            return .available(biometryType)
        }
        
        guard let laError = error as? LAError else {
            return .notAvailable
        }
        
        switch laError.code {
        case .biometryNotAvailable:
            return .notAvailable
            
        case .biometryNotEnrolled:
            return .notEnrolled(biometryType)
            
        case .biometryLockout:
            return .lockedOut(biometryType)
            
        case .passcodeNotSet:
            return .passcodeNotSet
            
        default:
            return .notAvailable
        }
    }
    
    // MARK: - 표시 속성
    
    /// 상태 설명
    var description: String {
        switch self {
        case .available(let type):
            return "\(type.displayName) 사용 가능"
        case .notAvailable:
            return "생체 인증을 지원하지 않는 기기입니다"
        case .notEnrolled(let type):
            return "\(type.displayName)가 등록되어 있지 않습니다"
        case .lockedOut(let type):
            return "\(type.displayName)가 잠겼습니다. 기기 암호로 잠금 해제가 필요합니다"
        case .passcodeNotSet:
            return "기기 암호가 설정되어 있지 않습니다"
        case .denied:
            return "생체 인증 권한이 거부되었습니다"
        }
    }
    
    /// 복구 방법 안내
    var recoveryHint: String? {
        switch self {
        case .available:
            return nil
        case .notAvailable:
            return nil
        case .notEnrolled(let type):
            return "\(type.settingsPath)에서 등록해주세요"
        case .lockedOut:
            return "기기 암호를 입력하여 잠금을 해제해주세요"
        case .passcodeNotSet:
            return "설정 > Face ID 및 암호에서 암호를 설정해주세요"
        case .denied:
            return "설정 > 개인정보 보호에서 권한을 허용해주세요"
        }
    }
    
    /// SF Symbol 아이콘
    var iconName: String {
        switch self {
        case .available(let type):
            return type.iconName
        case .notAvailable:
            return "xmark.shield.fill"
        case .notEnrolled:
            return "person.badge.plus"
        case .lockedOut:
            return "lock.shield.fill"
        case .passcodeNotSet:
            return "lock.open.fill"
        case .denied:
            return "hand.raised.slash.fill"
        }
    }
    
    /// 상태 색상
    var color: Color {
        switch self {
        case .available:
            return .green
        case .notAvailable, .denied:
            return .gray
        case .notEnrolled:
            return .orange
        case .lockedOut:
            return .red
        case .passcodeNotSet:
            return .yellow
        }
    }
    
    /// 사용 가능 여부
    var isUsable: Bool {
        if case .available = self {
            return true
        }
        return false
    }
    
    /// 설정에서 해결 가능한 문제인지
    var canBeResolvedInSettings: Bool {
        switch self {
        case .notEnrolled, .passcodeNotSet, .denied:
            return true
        default:
            return false
        }
    }
}

// MARK: - 인증 정책 래퍼
/// LAPolicy를 래핑하여 사용하기 쉽게 만든 열거형
enum AuthenticationPolicy: Equatable {
    /// 생체 인증만 사용 (실패 시 암호 입력 불가)
    case biometricsOnly
    
    /// 생체 인증 우선, 실패/불가 시 기기 암호로 대체
    case biometricsOrPasscode
    
    /// 기기 암호만 사용
    case passcodeOnly
    
    /// 대응하는 LAPolicy
    var laPolicy: LAPolicy {
        switch self {
        case .biometricsOnly:
            return .deviceOwnerAuthenticationWithBiometrics
        case .biometricsOrPasscode:
            return .deviceOwnerAuthentication
        case .passcodeOnly:
            return .deviceOwnerAuthentication
        }
    }
    
    /// 설명 문자열
    var description: String {
        switch self {
        case .biometricsOnly:
            return "생체 인증만 허용"
        case .biometricsOrPasscode:
            return "생체 인증 또는 암호"
        case .passcodeOnly:
            return "암호만 허용"
        }
    }
    
    /// 권장 정책 (기기 상태에 따라)
    static var recommended: AuthenticationPolicy {
        let status = BiometricStatus.current
        
        switch status {
        case .available:
            return .biometricsOrPasscode
        default:
            return .passcodeOnly
        }
    }
}

// MARK: - 인증 결과
/// 인증 시도의 결과를 나타내는 열거형
enum AuthenticationResult: Equatable {
    /// 성공
    case success
    
    /// 실패 (재시도 가능)
    case failed(SecurityError)
    
    /// 취소됨
    case cancelled
    
    /// 폴백 요청 (사용자가 암호 입력 선택)
    case fallbackRequested
    
    /// 잠금됨 (너무 많은 실패)
    case lockedOut
    
    /// 성공 여부
    var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }
    
    /// 재시도 가능 여부
    var canRetry: Bool {
        switch self {
        case .failed, .cancelled, .fallbackRequested:
            return true
        case .success, .lockedOut:
            return false
        }
    }
    
    /// 사용자에게 표시할 메시지
    var message: String? {
        switch self {
        case .success:
            return nil
        case .failed(let error):
            return error.errorDescription
        case .cancelled:
            return "인증이 취소되었습니다"
        case .fallbackRequested:
            return nil
        case .lockedOut:
            return "너무 많은 시도로 잠겼습니다. 기기 암호를 입력해주세요"
        }
    }
}

// MARK: - Preview 지원
#if DEBUG
extension BiometryType {
    /// 미리보기용 모든 유형 배열
    static let allForPreview: [BiometryType] = [.faceID, .touchID, .opticID, .none]
}

extension BiometricStatus {
    /// 미리보기용 모든 상태 배열
    static let allForPreview: [BiometricStatus] = [
        .available(.faceID),
        .available(.touchID),
        .notAvailable,
        .notEnrolled(.faceID),
        .lockedOut(.touchID),
        .passcodeNotSet,
        .denied
    ]
}
#endif
