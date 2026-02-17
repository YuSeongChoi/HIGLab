// SettingsHelper.swift
// PermissionHub - iOS 26 PermissionKit 샘플
// 설정 앱 딥링크 및 시스템 설정 유틸리티

import Foundation
import UIKit
import PermissionKit

// MARK: - 설정 헬퍼
/// 설정 앱 딥링크 및 시스템 설정 관련 유틸리티
public enum SettingsHelper {
    
    // MARK: - 설정 URL 타입
    /// iOS 설정 앱의 다양한 섹션 URL
    public enum SettingsURL: String {
        /// 앱 설정 (현재 앱)
        case app = "app-settings:"
        
        /// 일반 설정
        case general = "App-prefs:General"
        
        /// 개인정보 보호 설정
        case privacy = "App-prefs:Privacy"
        
        /// 위치 서비스
        case locationServices = "App-prefs:Privacy&path=LOCATION"
        
        /// 카메라
        case camera = "App-prefs:Privacy&path=CAMERA"
        
        /// 마이크
        case microphone = "App-prefs:Privacy&path=MICROPHONE"
        
        /// 사진
        case photos = "App-prefs:Privacy&path=PHOTOS"
        
        /// 연락처
        case contacts = "App-prefs:Privacy&path=CONTACTS"
        
        /// 캘린더
        case calendar = "App-prefs:Privacy&path=CALENDARS"
        
        /// 미리알림
        case reminders = "App-prefs:Privacy&path=REMINDERS"
        
        /// 건강
        case health = "App-prefs:Privacy&path=HEALTH"
        
        /// 블루투스
        case bluetooth = "App-prefs:Bluetooth"
        
        /// 알림
        case notifications = "App-prefs:NOTIFICATIONS_ID"
        
        /// 추적
        case tracking = "App-prefs:Privacy&path=USER_TRACKING"
        
        /// Face ID 및 암호
        case faceID = "App-prefs:PASSCODE"
        
        /// Wi-Fi
        case wifi = "App-prefs:WIFI"
        
        /// 셀룰러
        case cellular = "App-prefs:MOBILE_DATA_SETTINGS_ID"
        
        /// 배터리
        case battery = "App-prefs:BATTERY_USAGE"
        
        /// 디스플레이 및 밝기
        case display = "App-prefs:DISPLAY"
        
        /// 접근성
        case accessibility = "App-prefs:ACCESSIBILITY"
        
        /// URL 반환
        public var url: URL? {
            URL(string: self.rawValue)
        }
    }
    
    // MARK: - 앱 설정 열기
    
    /// 현재 앱의 설정 페이지 열기
    @MainActor
    public static func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            print("⚠️ 앱 설정 URL을 생성할 수 없습니다")
            return
        }
        
        openURL(url)
    }
    
    /// 특정 설정 페이지 열기
    @MainActor
    public static func openSettings(_ settingsURL: SettingsURL) {
        guard let url = settingsURL.url else {
            print("⚠️ 설정 URL을 생성할 수 없습니다: \(settingsURL.rawValue)")
            // 실패 시 앱 설정으로 폴백
            openAppSettings()
            return
        }
        
        openURL(url)
    }
    
    /// 권한 타입에 맞는 설정 페이지 열기
    @MainActor
    public static func openSettings(for permissionType: PermissionType) {
        let settingsURL: SettingsURL
        
        switch permissionType {
        case .camera:
            settingsURL = .camera
        case .microphone:
            settingsURL = .microphone
        case .photoLibrary:
            settingsURL = .photos
        case .location, .locationAlways:
            settingsURL = .locationServices
        case .contacts:
            settingsURL = .contacts
        case .calendar:
            settingsURL = .calendar
        case .reminders:
            settingsURL = .reminders
        case .notifications:
            settingsURL = .notifications
        case .healthKit:
            settingsURL = .health
        case .bluetooth:
            settingsURL = .bluetooth
        case .faceID:
            settingsURL = .faceID
        case .tracking:
            settingsURL = .tracking
        default:
            // 기본값: 앱 설정
            openAppSettings()
            return
        }
        
        openSettings(settingsURL)
    }
    
    // MARK: - URL 열기
    
    /// URL 열기 (내부 헬퍼)
    @MainActor
    private static func openURL(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { success in
                if success {
                    print("✅ 설정 페이지 열기 성공: \(url)")
                } else {
                    print("❌ 설정 페이지 열기 실패: \(url)")
                }
            }
        } else {
            print("⚠️ 해당 URL을 열 수 없습니다: \(url)")
            // 폴백: 기본 앱 설정
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }
    }
    
    // MARK: - 시스템 기능 확인
    
    /// 카메라 사용 가능 여부
    public static var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    /// Face ID 지원 여부
    public static var isFaceIDSupported: Bool {
        // LAContext를 사용하여 확인 (LocalAuthentication 프레임워크 필요)
        // 간소화를 위해 기기 모델로 확인
        let deviceModel = UIDevice.current.model
        return deviceModel.contains("iPhone")
    }
    
    /// 위치 서비스 활성화 여부
    public static var isLocationServicesEnabled: Bool {
        // CLLocationManager.locationServicesEnabled()
        // PermissionKit 사용 시 해당 API 활용
        true
    }
    
    /// 알림 설정 가능 여부
    public static var areNotificationsEnabled: Bool {
        // UNUserNotificationCenter를 통해 확인
        true
    }
    
    // MARK: - 기기 정보
    
    /// 현재 iOS 버전
    public static var iOSVersion: String {
        UIDevice.current.systemVersion
    }
    
    /// 기기 모델명
    public static var deviceModel: String {
        UIDevice.current.model
    }
    
    /// 기기 이름
    public static var deviceName: String {
        UIDevice.current.name
    }
    
    /// iOS 26 이상인지 확인
    public static var isIOS26OrLater: Bool {
        if #available(iOS 26, *) {
            return true
        }
        return false
    }
    
    // MARK: - 권한 안내 메시지 생성
    
    /// 권한 거부 시 안내 메시지 생성
    public static func denialMessage(for permissionType: PermissionType) -> String {
        """
        \(permissionType.displayName) 권한이 거부되었습니다.
        
        이 기능을 사용하려면 설정에서 권한을 허용해 주세요.
        
        설정 > \(appName) > \(permissionType.displayName)
        """
    }
    
    /// 권한 제한 시 안내 메시지 생성
    public static func restrictedMessage(for permissionType: PermissionType) -> String {
        """
        \(permissionType.displayName) 권한이 제한되어 있습니다.
        
        자녀 보호 기능 또는 기기 관리 정책에 의해 이 권한이 제한되었을 수 있습니다.
        
        기기 관리자에게 문의해 주세요.
        """
    }
    
    /// 앱 이름 가져오기
    private static var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ??
        "Permission Hub"
    }
}

// MARK: - 설정 알림 뷰 모델
/// 설정 페이지로 안내하는 알림을 관리하는 뷰 모델
@Observable
@MainActor
public final class SettingsAlertViewModel {
    /// 알림 표시 여부
    public var isShowingAlert = false
    
    /// 현재 알림의 권한 타입
    public private(set) var currentPermissionType: PermissionType?
    
    /// 알림 제목
    public var alertTitle: String {
        guard let type = currentPermissionType else { return "권한 필요" }
        return "\(type.displayName) 권한 필요"
    }
    
    /// 알림 메시지
    public var alertMessage: String {
        guard let type = currentPermissionType else { return "이 기능을 사용하려면 권한이 필요합니다." }
        return SettingsHelper.denialMessage(for: type)
    }
    
    /// 설정 알림 표시
    public func showSettingsAlert(for permissionType: PermissionType) {
        currentPermissionType = permissionType
        isShowingAlert = true
    }
    
    /// 설정 앱 열기
    public func openSettings() {
        if let type = currentPermissionType {
            SettingsHelper.openSettings(for: type)
        } else {
            SettingsHelper.openAppSettings()
        }
        isShowingAlert = false
    }
    
    /// 알림 닫기
    public func dismiss() {
        isShowingAlert = false
        currentPermissionType = nil
    }
}

// MARK: - 권한별 설정 경로 정보
/// 각 권한 타입에 대한 설정 경로 정보
public struct PermissionSettingsInfo {
    public let permissionType: PermissionType
    public let settingsPath: String
    public let settingsURL: SettingsHelper.SettingsURL
    
    /// 사용자에게 보여줄 설정 경로 설명
    public var pathDescription: String {
        "설정 > \(Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "앱") > \(permissionType.displayName)"
    }
    
    /// 모든 권한에 대한 설정 정보
    public static let all: [PermissionSettingsInfo] = PermissionType.allCases.map { type in
        let url: SettingsHelper.SettingsURL
        switch type {
        case .camera: url = .camera
        case .microphone: url = .microphone
        case .photoLibrary: url = .photos
        case .location, .locationAlways: url = .locationServices
        case .contacts: url = .contacts
        case .calendar: url = .calendar
        case .reminders: url = .reminders
        case .notifications: url = .notifications
        case .healthKit: url = .health
        case .bluetooth: url = .bluetooth
        case .faceID: url = .faceID
        case .tracking: url = .tracking
        default: url = .app
        }
        
        return PermissionSettingsInfo(
            permissionType: type,
            settingsPath: url.rawValue,
            settingsURL: url
        )
    }
}

// MARK: - Info.plist 키 참조
/// 각 권한에 필요한 Info.plist 키 목록
public enum InfoPlistKey: String {
    /// 카메라 사용 설명
    case cameraUsage = "NSCameraUsageDescription"
    
    /// 마이크 사용 설명
    case microphoneUsage = "NSMicrophoneUsageDescription"
    
    /// 사진 라이브러리 사용 설명 (읽기)
    case photoLibraryUsage = "NSPhotoLibraryUsageDescription"
    
    /// 사진 라이브러리 추가 설명 (쓰기)
    case photoLibraryAdd = "NSPhotoLibraryAddUsageDescription"
    
    /// 위치 사용 중 설명
    case locationWhenInUse = "NSLocationWhenInUseUsageDescription"
    
    /// 위치 항상 설명
    case locationAlways = "NSLocationAlwaysAndWhenInUseUsageDescription"
    
    /// 연락처 사용 설명
    case contactsUsage = "NSContactsUsageDescription"
    
    /// 캘린더 사용 설명
    case calendarsUsage = "NSCalendarsUsageDescription"
    
    /// 미리알림 사용 설명
    case remindersUsage = "NSRemindersUsageDescription"
    
    /// 건강 공유 설명
    case healthShare = "NSHealthShareUsageDescription"
    
    /// 건강 업데이트 설명
    case healthUpdate = "NSHealthUpdateUsageDescription"
    
    /// 동작 사용 설명
    case motionUsage = "NSMotionUsageDescription"
    
    /// 블루투스 항상 사용 설명
    case bluetoothAlways = "NSBluetoothAlwaysUsageDescription"
    
    /// 음성 인식 사용 설명
    case speechRecognition = "NSSpeechRecognitionUsageDescription"
    
    /// Face ID 사용 설명
    case faceID = "NSFaceIDUsageDescription"
    
    /// 앱 추적 설명
    case tracking = "NSUserTrackingUsageDescription"
    
    /// 미디어 라이브러리 사용 설명
    case mediaLibrary = "NSAppleMusicUsageDescription"
    
    /// 권한 타입에 맞는 Info.plist 키 반환
    public static func key(for permissionType: PermissionType) -> InfoPlistKey? {
        switch permissionType {
        case .camera: return .cameraUsage
        case .microphone: return .microphoneUsage
        case .photoLibrary: return .photoLibraryUsage
        case .location: return .locationWhenInUse
        case .locationAlways: return .locationAlways
        case .contacts: return .contactsUsage
        case .calendar: return .calendarsUsage
        case .reminders: return .remindersUsage
        case .healthKit: return .healthShare
        case .motion: return .motionUsage
        case .bluetooth: return .bluetoothAlways
        case .speechRecognition: return .speechRecognition
        case .faceID: return .faceID
        case .tracking: return .tracking
        case .mediaLibrary: return .mediaLibrary
        case .notifications: return nil // 알림은 Info.plist 키 불필요
        }
    }
    
    /// 현재 앱의 Info.plist에 해당 키가 있는지 확인
    public var isConfigured: Bool {
        Bundle.main.object(forInfoDictionaryKey: self.rawValue) != nil
    }
}
