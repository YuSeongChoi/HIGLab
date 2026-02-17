// PermissionHubApp.swift
// PermissionHub - iOS 26 PermissionKit 샘플
// 앱 엔트리 포인트 및 초기 설정

import SwiftUI
import PermissionKit

// MARK: - 앱 엔트리 포인트
@main
struct PermissionHubApp: App {
    /// 권한 관리자 (앱 전역에서 공유)
    @State private var permissionManager = PermissionManager()
    
    /// 온보딩 완료 여부
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    /// 앱 시작 시 권한 체크 완료 여부
    @State private var hasCheckedPermissions = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    // 메인 컨텐츠 화면
                    ContentView()
                        .environment(permissionManager)
                        .onAppear {
                            // 앱 시작 시 권한 상태 확인
                            checkPermissionsOnLaunch()
                        }
                } else {
                    // 온보딩 화면
                    OnboardingPermissionView(hasCompletedOnboarding: $hasCompletedOnboarding)
                        .environment(permissionManager)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                // 앱이 활성화될 때마다 권한 상태 갱신
                Task {
                    await permissionManager.refreshAllPermissionStatuses()
                }
            }
        }
    }
    
    // MARK: - 앱 시작 시 권한 확인
    /// 앱 실행 시 한 번 권한 상태를 확인합니다
    private func checkPermissionsOnLaunch() {
        guard !hasCheckedPermissions else { return }
        hasCheckedPermissions = true
        
        Task {
            // iOS 26 PermissionKit 초기화
            await permissionManager.initialize()
            
            // 모든 권한 상태 조회
            await permissionManager.refreshAllPermissionStatuses()
            
            // 권한 변경 감지 시작
            permissionManager.startMonitoringChanges()
        }
    }
}

// MARK: - 앱 델리게이트 어댑터
/// UIKit 앱 델리게이트가 필요한 경우 사용
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // 앱 시작 로깅
        print("🚀 PermissionHub 앱 시작")
        print("📱 iOS 버전: \(ProcessInfo.processInfo.operatingSystemVersionString)")
        
        // PermissionKit 프레임워크 버전 확인
        if let frameworkVersion = PermissionConfiguration.frameworkVersion {
            print("🔐 PermissionKit 버전: \(frameworkVersion)")
        }
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // 앱 활성화 시 추가 작업
        print("📲 앱 활성화됨")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // 앱 비활성화 시 상태 저장
        print("💤 앱 비활성화됨")
    }
}

// MARK: - PermissionKit 설정
/// iOS 26 PermissionKit 전역 설정
struct PermissionConfiguration {
    /// PermissionKit 프레임워크 버전
    static var frameworkVersion: String? {
        // iOS 26 PermissionKit의 버전 정보 조회
        return "1.0.0" // PermissionKit.version
    }
    
    /// 권한 요청 시 사용할 기본 옵션
    static var defaultRequestOptions: PermissionRequestOptions {
        PermissionRequestOptions(
            // 사용자에게 왜 권한이 필요한지 설명 표시
            showsUsageDescription: true,
            // 거부 시 자동으로 설정 앱으로 안내
            offersSettingsNavigation: true,
            // 요청 대화상자 애니메이션
            animated: true,
            // 요청 타임아웃 (초)
            timeout: 60
        )
    }
    
    /// 모니터링할 권한 목록
    static var monitoredPermissions: [PermissionType] {
        [
            .camera,
            .microphone,
            .photoLibrary,
            .location,
            .contacts,
            .notifications
        ]
    }
}

// MARK: - PermissionKit 타입 별칭
/// iOS 26 PermissionKit 타입에 대한 별칭 (가독성 향상)
typealias PKAuthorizationStatus = PermissionKit.AuthorizationStatus
typealias PKPermissionKey = PermissionKit.PermissionKey
typealias PKRequestOptions = PermissionKit.PermissionRequestOptions

// MARK: - 권한 요청 옵션 확장
/// iOS 26 PermissionKit의 PermissionRequestOptions를 확장
extension PermissionRequestOptions {
    /// 빠른 권한 요청용 기본 옵션
    static var quick: PermissionRequestOptions {
        PermissionRequestOptions(
            showsUsageDescription: false,
            offersSettingsNavigation: false,
            animated: true,
            timeout: 30
        )
    }
    
    /// 상세 설명을 포함한 권한 요청 옵션
    static var detailed: PermissionRequestOptions {
        PermissionRequestOptions(
            showsUsageDescription: true,
            offersSettingsNavigation: true,
            animated: true,
            timeout: 120
        )
    }
}
