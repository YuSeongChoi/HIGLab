// PermissionManager.swift
// PermissionHub - iOS 26 PermissionKit 샘플
// 통합 권한 관리자 - iOS 26 PermissionKit 활용

import Foundation
import SwiftUI
import PermissionKit
import Combine

// MARK: - 권한 관리자
/// iOS 26 PermissionKit을 사용하여 모든 권한을 통합 관리하는 클래스
/// @Observable 매크로를 사용하여 SwiftUI와 자동 연동됩니다
@Observable
@MainActor
public final class PermissionManager {
    
    // MARK: - 상태 프로퍼티
    
    /// 모든 권한의 현재 상태
    public private(set) var permissions: [PermissionType: PermissionInfo] = [:]
    
    /// 권한 변경 이력
    public private(set) var changeHistory: [PermissionChangeEvent] = []
    
    /// 초기화 완료 여부
    public private(set) var isInitialized = false
    
    /// 권한 요청 중인지 여부
    public private(set) var isRequesting = false
    
    /// 현재 요청 중인 권한 타입
    public private(set) var currentlyRequestingType: PermissionType?
    
    /// 마지막 에러
    public private(set) var lastError: PermissionError?
    
    // MARK: - iOS 26 PermissionKit 인스턴스
    
    /// PermissionKit 통합 관리자
    private let permissionKit: PermissionKitManager
    
    /// 권한 변경 감지 토큰
    private var observationTokens: [PermissionType: PermissionObservationToken] = [:]
    
    /// 변경 감지 활성화 여부
    private var isMonitoring = false
    
    // MARK: - 초기화
    
    public init() {
        // iOS 26 PermissionKit 통합 관리자 초기화
        self.permissionKit = PermissionKitManager.shared
        
        // 모든 권한 타입에 대해 초기 상태 설정
        for type in PermissionType.allCases {
            permissions[type] = PermissionInfo(
                type: type,
                status: .notDetermined
            )
        }
    }
    
    // MARK: - 초기화 및 설정
    
    /// PermissionKit 초기화 및 설정
    public func initialize() async {
        guard !isInitialized else { return }
        
        do {
            // iOS 26 PermissionKit 초기화
            try await permissionKit.initialize(
                with: PermissionKitConfiguration(
                    // 앱 번들 ID 자동 감지
                    bundleIdentifier: Bundle.main.bundleIdentifier,
                    // 권한 상태 캐싱 활성화
                    enableCaching: true,
                    // 캐시 만료 시간 (초)
                    cacheExpirationSeconds: 300,
                    // 상세 로깅 활성화
                    verboseLogging: true
                )
            )
            
            isInitialized = true
            print("✅ PermissionKit 초기화 완료")
            
        } catch {
            print("❌ PermissionKit 초기화 실패: \(error)")
            lastError = .frameworkError(
                PermissionKitError(code: -1, message: error.localizedDescription)
            )
        }
    }
    
    // MARK: - 권한 상태 조회
    
    /// 특정 권한의 현재 상태 조회
    public func checkStatus(for type: PermissionType) async -> PermissionStatus {
        do {
            // iOS 26 PermissionKit으로 상태 조회
            let authStatus = try await permissionKit.authorizationStatus(for: type.permissionKey)
            let status = PermissionStatus(from: authStatus)
            
            // 상태 업데이트
            updatePermissionStatus(type: type, status: status)
            
            return status
            
        } catch {
            print("⚠️ 권한 상태 조회 실패 (\(type.displayName)): \(error)")
            return .unsupported
        }
    }
    
    /// 모든 권한 상태 갱신
    public func refreshAllPermissionStatuses() async {
        print("🔄 모든 권한 상태 갱신 시작...")
        
        // 병렬로 모든 권한 상태 조회
        await withTaskGroup(of: Void.self) { group in
            for type in PermissionType.allCases {
                group.addTask {
                    _ = await self.checkStatus(for: type)
                }
            }
        }
        
        print("✅ 모든 권한 상태 갱신 완료")
    }
    
    /// 특정 권한 정보 가져오기
    public func permissionInfo(for type: PermissionType) -> PermissionInfo {
        permissions[type] ?? PermissionInfo(type: type)
    }
    
    /// 특정 그룹의 권한 목록 가져오기
    public func permissions(in group: PermissionGroup) -> [PermissionInfo] {
        group.permissions.compactMap { permissions[$0] }
    }
    
    // MARK: - 권한 요청
    
    /// 단일 권한 요청
    public func requestPermission(for type: PermissionType) async -> PermissionResult {
        // 중복 요청 방지
        guard !isRequesting else {
            return .failure(.unknown(type, underlyingError: nil))
        }
        
        // 이미 결정된 권한인지 확인
        if let info = permissions[type], !info.status.canRequest {
            return .failure(.alreadyDetermined(type, currentStatus: info.status))
        }
        
        isRequesting = true
        currentlyRequestingType = type
        
        defer {
            isRequesting = false
            currentlyRequestingType = nil
        }
        
        do {
            print("📝 권한 요청 시작: \(type.displayName)")
            
            // iOS 26 PermissionKit으로 권한 요청
            let result = try await permissionKit.requestAuthorization(
                for: type.permissionKey,
                options: PermissionConfiguration.defaultRequestOptions
            )
            
            let status = PermissionStatus(from: result.status)
            
            // 상태 업데이트
            updatePermissionStatus(type: type, status: status, source: .appRequest)
            
            // 결과 반환
            if status.isGranted {
                print("✅ 권한 허용됨: \(type.displayName)")
                return .success(status)
            } else {
                print("❌ 권한 거부됨: \(type.displayName)")
                return .failure(.denied(type))
            }
            
        } catch {
            print("❌ 권한 요청 실패: \(error)")
            lastError = .unknown(type, underlyingError: error)
            return .failure(.unknown(type, underlyingError: error))
        }
    }
    
    /// 여러 권한 동시 요청
    public func requestPermissions(for types: [PermissionType]) async -> [PermissionType: PermissionResult] {
        var results: [PermissionType: PermissionResult] = [:]
        
        // 순차적으로 권한 요청 (iOS 정책상 동시 요청 불가)
        for type in types {
            // 잠시 대기하여 사용자 경험 개선
            try? await Task.sleep(for: .milliseconds(300))
            
            let result = await requestPermission(for: type)
            results[type] = result
        }
        
        return results
    }
    
    /// 필수 권한만 요청
    public func requestEssentialPermissions() async -> Bool {
        let essentialTypes = PermissionType.allCases.filter { $0.isEssential }
        let results = await requestPermissions(for: essentialTypes)
        
        // 모든 필수 권한이 허용되었는지 확인
        return results.values.allSatisfy { $0.isGranted }
    }
    
    // MARK: - 권한 변경 감지
    
    /// 권한 변경 감지 시작
    public func startMonitoringChanges() {
        guard !isMonitoring else { return }
        isMonitoring = true
        
        print("👁️ 권한 변경 감지 시작")
        
        // iOS 26 PermissionKit의 변경 감지 API 사용
        for type in PermissionConfiguration.monitoredPermissions {
            let token = permissionKit.observeAuthorizationChanges(
                for: type.permissionKey
            ) { [weak self] newStatus in
                Task { @MainActor in
                    self?.handlePermissionChange(
                        type: type,
                        newStatus: PermissionStatus(from: newStatus)
                    )
                }
            }
            
            observationTokens[type] = token
        }
    }
    
    /// 권한 변경 감지 중지
    public func stopMonitoringChanges() {
        guard isMonitoring else { return }
        isMonitoring = false
        
        print("🛑 권한 변경 감지 중지")
        
        // 모든 감지 토큰 해제
        for (_, token) in observationTokens {
            token.invalidate()
        }
        observationTokens.removeAll()
    }
    
    /// 권한 변경 처리
    private func handlePermissionChange(type: PermissionType, newStatus: PermissionStatus) {
        guard let currentInfo = permissions[type] else { return }
        
        // 상태가 실제로 변경되었는지 확인
        guard currentInfo.status != newStatus else { return }
        
        print("🔔 권한 변경 감지: \(type.displayName) - \(currentInfo.status.displayText) → \(newStatus.displayText)")
        
        // 변경 이벤트 기록
        let event = PermissionChangeEvent(
            permissionType: type,
            previousStatus: currentInfo.status,
            newStatus: newStatus,
            source: .systemSettings
        )
        changeHistory.append(event)
        
        // 상태 업데이트
        updatePermissionStatus(type: type, status: newStatus, source: .systemSettings)
    }
    
    // MARK: - 내부 유틸리티
    
    /// 권한 상태 업데이트
    private func updatePermissionStatus(
        type: PermissionType,
        status: PermissionStatus,
        source: PermissionChangeEvent.ChangeSource = .unknown
    ) {
        var info = permissions[type] ?? PermissionInfo(type: type)
        let previousStatus = info.status
        
        info.status = status
        info.lastChecked = Date()
        
        if previousStatus != status {
            info.changeCount += 1
            
            // 변경 이벤트 기록 (외부에서 호출된 경우 중복 방지)
            if source == .appRequest {
                let event = PermissionChangeEvent(
                    permissionType: type,
                    previousStatus: previousStatus,
                    newStatus: status,
                    source: source
                )
                changeHistory.append(event)
            }
        }
        
        permissions[type] = info
    }
    
    // MARK: - 통계 및 분석
    
    /// 현재 권한 상태 스냅샷 생성
    public func createSnapshot() -> PermissionSnapshot {
        let allPermissions = PermissionType.allCases.compactMap { permissions[$0] }
        return PermissionSnapshot(permissions: allPermissions)
    }
    
    /// 허용된 권한 목록
    public var grantedPermissions: [PermissionInfo] {
        permissions.values.filter { $0.status.isGranted }
    }
    
    /// 거부된 권한 목록
    public var deniedPermissions: [PermissionInfo] {
        permissions.values.filter { $0.status == .denied }
    }
    
    /// 아직 요청하지 않은 권한 목록
    public var pendingPermissions: [PermissionInfo] {
        permissions.values.filter { $0.status == .notDetermined }
    }
    
    /// 전체 허용률
    public var overallGrantedRatio: Double {
        let total = Double(permissions.count)
        guard total > 0 else { return 0 }
        return Double(grantedPermissions.count) / total
    }
    
    // MARK: - 에러 처리
    
    /// 마지막 에러 초기화
    public func clearLastError() {
        lastError = nil
    }
    
    /// 변경 이력 초기화
    public func clearChangeHistory() {
        changeHistory.removeAll()
    }
}

// MARK: - PermissionKit 타입 정의 (iOS 26 API)
/// iOS 26 PermissionKit 프레임워크 타입들
/// 실제 iOS 26에서는 시스템 프레임워크에서 제공됩니다

/// PermissionKit 통합 관리자
public class PermissionKitManager: @unchecked Sendable {
    public static let shared = PermissionKitManager()
    
    private init() {}
    
    /// 초기화
    public func initialize(with configuration: PermissionKitConfiguration) async throws {
        // iOS 26 PermissionKit 초기화 로직
    }
    
    /// 권한 상태 조회
    public func authorizationStatus(for key: PermissionKey) async throws -> AuthorizationStatus {
        // 실제 구현에서는 시스템 API 호출
        return .notDetermined
    }
    
    /// 권한 요청
    public func requestAuthorization(
        for key: PermissionKey,
        options: PermissionRequestOptions
    ) async throws -> PermissionRequestResult {
        // 실제 구현에서는 시스템 권한 대화상자 표시
        return PermissionRequestResult(status: .authorized)
    }
    
    /// 권한 변경 감지
    public func observeAuthorizationChanges(
        for key: PermissionKey,
        handler: @escaping (AuthorizationStatus) -> Void
    ) -> PermissionObservationToken {
        return PermissionObservationToken()
    }
}

/// PermissionKit 설정
public struct PermissionKitConfiguration: Sendable {
    public let bundleIdentifier: String?
    public let enableCaching: Bool
    public let cacheExpirationSeconds: Int
    public let verboseLogging: Bool
    
    public init(
        bundleIdentifier: String? = nil,
        enableCaching: Bool = true,
        cacheExpirationSeconds: Int = 300,
        verboseLogging: Bool = false
    ) {
        self.bundleIdentifier = bundleIdentifier
        self.enableCaching = enableCaching
        self.cacheExpirationSeconds = cacheExpirationSeconds
        self.verboseLogging = verboseLogging
    }
}

/// 권한 키
public enum PermissionKey: String, Sendable {
    case camera, microphone, photoLibrary
    case locationWhenInUse, locationAlways
    case contacts, calendar, reminders
    case notifications, healthKit, motion
    case bluetooth, speechRecognition
    case faceID, appTracking, mediaLibrary
}

/// 권한 상태
public enum AuthorizationStatus: Int, Sendable {
    case notDetermined = 0
    case authorized = 1
    case denied = 2
    case restricted = 3
    case limited = 4
    case provisional = 5
}

/// 권한 요청 옵션
public struct PermissionRequestOptions: Sendable {
    public let showsUsageDescription: Bool
    public let offersSettingsNavigation: Bool
    public let animated: Bool
    public let timeout: TimeInterval
    
    public init(
        showsUsageDescription: Bool = true,
        offersSettingsNavigation: Bool = true,
        animated: Bool = true,
        timeout: TimeInterval = 60
    ) {
        self.showsUsageDescription = showsUsageDescription
        self.offersSettingsNavigation = offersSettingsNavigation
        self.animated = animated
        self.timeout = timeout
    }
}

/// 권한 요청 결과
public struct PermissionRequestResult: Sendable {
    public let status: AuthorizationStatus
    
    public init(status: AuthorizationStatus) {
        self.status = status
    }
}

/// 권한 감지 토큰
public class PermissionObservationToken: @unchecked Sendable {
    public func invalidate() {
        // 감지 해제
    }
}
