#if canImport(PermissionKit)
import PermissionKit
import SwiftUI
import AVFoundation
import CoreLocation
import UserNotifications

// 온보딩 권한 상태 관리
@Observable
final class OnboardingViewModel {
    // 각 권한의 상태
    var notificationStatus: UNAuthorizationStatus = .notDetermined
    var cameraStatus: AVAuthorizationStatus = .notDetermined
    var locationStatus: CLAuthorizationStatus = .notDetermined
    
    // 현재 단계
    var currentStep: OnboardingStep = .welcome
    
    // 온보딩 완료 여부
    var isOnboardingComplete = false
    
    enum OnboardingStep: Int, CaseIterable {
        case welcome = 0
        case notifications = 1
        case camera = 2
        case location = 3
        case complete = 4
        
        var title: String {
            switch self {
            case .welcome: return "시작하기"
            case .notifications: return "알림"
            case .camera: return "카메라"
            case .location: return "위치"
            case .complete: return "완료"
            }
        }
    }
    
    init() {
        refreshAllStatuses()
    }
    
    func refreshAllStatuses() {
        // 알림 상태
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            Task { @MainActor in
                self.notificationStatus = settings.authorizationStatus
            }
        }
        
        // 카메라 상태
        cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        // 위치 상태
        locationStatus = CLLocationManager().authorizationStatus
    }
    
    func goToNextStep() {
        if let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) {
            withAnimation {
                currentStep = nextStep
            }
        }
    }
    
    func skipCurrentStep() {
        goToNextStep()
    }
    
    func completeOnboarding() {
        isOnboardingComplete = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
    
    /// 모든 필수 권한이 허용되었는지 확인
    var allRequiredPermissionsGranted: Bool {
        notificationStatus == .authorized
    }
    
    /// 선택적 권한 중 허용된 수
    var optionalPermissionsGrantedCount: Int {
        var count = 0
        if cameraStatus == .authorized { count += 1 }
        if locationStatus == .authorizedWhenInUse || locationStatus == .authorizedAlways { count += 1 }
        return count
    }
}

// iOS 26 PermissionKit - HIG Lab
#endif
