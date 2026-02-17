// PermissionError.swift
// PermissionHub - iOS 26 PermissionKit 샘플
// 권한 관련 에러 타입 정의

import Foundation
import PermissionKit

// MARK: - 권한 에러 타입
/// 권한 처리 중 발생할 수 있는 모든 에러를 정의합니다
public enum PermissionError: LocalizedError, Sendable {
    /// 권한 요청이 거부됨
    case denied(PermissionType)
    
    /// 시스템에서 권한이 제한됨
    case restricted(PermissionType)
    
    /// 이미 권한이 결정된 상태에서 다시 요청 시도
    case alreadyDetermined(PermissionType, currentStatus: PermissionStatus)
    
    /// 해당 기기에서 지원하지 않는 권한
    case unsupported(PermissionType)
    
    /// 권한 요청 중 타임아웃 발생
    case timeout(PermissionType)
    
    /// 네트워크 연결 필요 (일부 권한 확인 시)
    case networkRequired
    
    /// iOS 버전이 너무 낮음
    case minimumOSVersionNotMet(required: String, current: String)
    
    /// Info.plist에 필수 설명이 없음
    case missingUsageDescription(PermissionType)
    
    /// 알 수 없는 에러
    case unknown(PermissionType, underlyingError: Error?)
    
    /// PermissionKit 프레임워크 에러
    case frameworkError(PermissionKitError)
    
    // MARK: - LocalizedError 준수
    public var errorDescription: String? {
        switch self {
        case .denied(let type):
            return "\(type.displayName) 권한이 거부되었습니다."
        case .restricted(let type):
            return "\(type.displayName) 권한이 시스템에서 제한되어 있습니다."
        case .alreadyDetermined(let type, let status):
            return "\(type.displayName) 권한이 이미 \(status.displayText) 상태입니다."
        case .unsupported(let type):
            return "\(type.displayName)은(는) 이 기기에서 지원되지 않습니다."
        case .timeout(let type):
            return "\(type.displayName) 권한 요청 시간이 초과되었습니다."
        case .networkRequired:
            return "네트워크 연결이 필요합니다."
        case .minimumOSVersionNotMet(let required, let current):
            return "iOS \(required) 이상이 필요합니다. 현재 버전: \(current)"
        case .missingUsageDescription(let type):
            return "\(type.displayName)에 대한 사용 설명이 Info.plist에 없습니다."
        case .unknown(let type, _):
            return "\(type.displayName) 권한 처리 중 알 수 없는 오류가 발생했습니다."
        case .frameworkError(let error):
            return "PermissionKit 오류: \(error.localizedDescription)"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .denied:
            return "사용자가 권한 요청을 거부했습니다."
        case .restricted:
            return "자녀 보호 기능 또는 기기 관리 정책에 의해 제한되었습니다."
        case .alreadyDetermined:
            return "권한이 이미 결정되어 다시 요청할 수 없습니다."
        case .unsupported:
            return "해당 하드웨어 또는 기능이 기기에 없습니다."
        case .timeout:
            return "사용자 응답을 기다리는 동안 시간이 초과되었습니다."
        case .networkRequired:
            return "일부 권한 확인에는 네트워크 연결이 필요합니다."
        case .minimumOSVersionNotMet:
            return "이 기능은 최신 iOS에서만 사용 가능합니다."
        case .missingUsageDescription:
            return "Apple 정책상 권한 요청 전 사용 목적을 명시해야 합니다."
        case .unknown(_, let underlyingError):
            if let error = underlyingError {
                return "원인: \(error.localizedDescription)"
            }
            return nil
        case .frameworkError:
            return "시스템 프레임워크에서 오류가 발생했습니다."
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .denied:
            return "설정 앱에서 권한을 허용해 주세요."
        case .restricted:
            return "기기 관리자에게 문의하거나 설정을 확인해 주세요."
        case .alreadyDetermined:
            return "설정 앱에서 권한 상태를 변경할 수 있습니다."
        case .unsupported:
            return "해당 기능이 있는 기기에서 사용해 주세요."
        case .timeout:
            return "다시 시도해 주세요."
        case .networkRequired:
            return "Wi-Fi 또는 셀룰러 데이터에 연결해 주세요."
        case .minimumOSVersionNotMet:
            return "기기의 iOS를 업데이트해 주세요."
        case .missingUsageDescription:
            return "개발자에게 문의해 주세요."
        case .unknown:
            return "앱을 재시작하거나 다시 시도해 주세요."
        case .frameworkError:
            return "앱을 재시작해 주세요."
        }
    }
    
    // MARK: - 에러 코드
    public var errorCode: Int {
        switch self {
        case .denied: return 1001
        case .restricted: return 1002
        case .alreadyDetermined: return 1003
        case .unsupported: return 1004
        case .timeout: return 1005
        case .networkRequired: return 1006
        case .minimumOSVersionNotMet: return 1007
        case .missingUsageDescription: return 1008
        case .unknown: return 1099
        case .frameworkError: return 2000
        }
    }
    
    // MARK: - 복구 가능 여부
    /// 사용자 액션으로 복구 가능한 에러인지 확인
    public var isRecoverable: Bool {
        switch self {
        case .denied, .timeout, .networkRequired:
            return true
        case .restricted, .alreadyDetermined, .unsupported,
             .minimumOSVersionNotMet, .missingUsageDescription,
             .unknown, .frameworkError:
            return false
        }
    }
    
    /// 설정 앱으로 이동하면 해결할 수 있는 에러인지 확인
    public var canResolveInSettings: Bool {
        switch self {
        case .denied, .alreadyDetermined, .restricted:
            return true
        default:
            return false
        }
    }
}

// MARK: - PermissionKit 에러 래핑
/// iOS 26 PermissionKit의 에러를 래핑하는 구조체
public struct PermissionKitError: LocalizedError, Sendable {
    public let code: Int
    public let message: String
    public let domain: String
    
    public init(code: Int, message: String, domain: String = "PermissionKit") {
        self.code = code
        self.message = message
        self.domain = domain
    }
    
    public var errorDescription: String? {
        "[\(domain)] \(message) (코드: \(code))"
    }
}

// MARK: - 에러 결과 타입
/// 권한 요청 결과를 표현하는 열거형
public enum PermissionResult: Sendable {
    /// 성공 - 권한이 허용됨
    case success(PermissionStatus)
    
    /// 실패 - 에러 발생
    case failure(PermissionError)
    
    /// 권한 상태를 반환 (실패 시 nil)
    public var status: PermissionStatus? {
        if case .success(let status) = self {
            return status
        }
        return nil
    }
    
    /// 에러를 반환 (성공 시 nil)
    public var error: PermissionError? {
        if case .failure(let error) = self {
            return error
        }
        return nil
    }
    
    /// 성공 여부
    public var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }
    
    /// 권한이 허용되었는지 확인
    public var isGranted: Bool {
        if case .success(let status) = self {
            return status.isGranted
        }
        return false
    }
}

// MARK: - 에러 로깅 유틸리티
/// 권한 에러를 로깅하기 위한 유틸리티
public struct PermissionErrorLogger {
    /// 에러 로그 레벨
    public enum LogLevel: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
    }
    
    /// 에러를 로그에 기록
    public static func log(
        _ error: PermissionError,
        level: LogLevel = .error,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fileName = (file as NSString).lastPathComponent
        let logMessage = """
        [\(level.rawValue)] PermissionError
        파일: \(fileName):\(line)
        함수: \(function)
        코드: \(error.errorCode)
        설명: \(error.errorDescription ?? "없음")
        원인: \(error.failureReason ?? "알 수 없음")
        해결: \(error.recoverySuggestion ?? "없음")
        """
        print(logMessage)
    }
    
    /// 에러를 딕셔너리로 변환 (분석용)
    public static func toDictionary(_ error: PermissionError) -> [String: Any] {
        return [
            "errorCode": error.errorCode,
            "description": error.errorDescription ?? "",
            "failureReason": error.failureReason ?? "",
            "recoverySuggestion": error.recoverySuggestion ?? "",
            "isRecoverable": error.isRecoverable,
            "canResolveInSettings": error.canResolveInSettings,
            "timestamp": Date().timeIntervalSince1970
        ]
    }
}
