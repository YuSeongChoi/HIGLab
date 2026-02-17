// PermissionType.swift
// PermissionHub - iOS 26 PermissionKit 샘플
// 지원하는 권한 타입 정의

import Foundation
import PermissionKit

// MARK: - 권한 타입 열거형
/// 앱에서 관리하는 모든 권한 타입을 정의합니다
/// iOS 26 PermissionKit의 Permission 프로토콜을 준수합니다
public enum PermissionType: String, CaseIterable, Identifiable, Sendable {
    case camera = "camera"
    case microphone = "microphone"
    case photoLibrary = "photoLibrary"
    case location = "location"
    case locationAlways = "locationAlways"
    case contacts = "contacts"
    case calendar = "calendar"
    case reminders = "reminders"
    case notifications = "notifications"
    case healthKit = "healthKit"
    case motion = "motion"
    case bluetooth = "bluetooth"
    case speechRecognition = "speechRecognition"
    case faceID = "faceID"
    case tracking = "tracking"
    case mediaLibrary = "mediaLibrary"
    
    public var id: String { rawValue }
    
    // MARK: - 표시 이름
    /// 사용자에게 보여줄 권한 이름 (한글)
    public var displayName: String {
        switch self {
        case .camera: return "카메라"
        case .microphone: return "마이크"
        case .photoLibrary: return "사진 라이브러리"
        case .location: return "위치 (사용 중)"
        case .locationAlways: return "위치 (항상)"
        case .contacts: return "연락처"
        case .calendar: return "캘린더"
        case .reminders: return "미리알림"
        case .notifications: return "알림"
        case .healthKit: return "건강"
        case .motion: return "동작 및 피트니스"
        case .bluetooth: return "블루투스"
        case .speechRecognition: return "음성 인식"
        case .faceID: return "Face ID"
        case .tracking: return "앱 추적"
        case .mediaLibrary: return "미디어 라이브러리"
        }
    }
    
    // MARK: - 시스템 아이콘
    /// SF Symbols 아이콘 이름
    public var iconName: String {
        switch self {
        case .camera: return "camera.fill"
        case .microphone: return "mic.fill"
        case .photoLibrary: return "photo.fill"
        case .location, .locationAlways: return "location.fill"
        case .contacts: return "person.crop.circle.fill"
        case .calendar: return "calendar"
        case .reminders: return "checklist"
        case .notifications: return "bell.fill"
        case .healthKit: return "heart.fill"
        case .motion: return "figure.walk"
        case .bluetooth: return "bluetooth"
        case .speechRecognition: return "waveform"
        case .faceID: return "faceid"
        case .tracking: return "hand.raised.fill"
        case .mediaLibrary: return "music.note"
        }
    }
    
    // MARK: - 권한 색상
    /// 권한 타입별 테마 색상
    public var themeColor: String {
        switch self {
        case .camera: return "systemBlue"
        case .microphone: return "systemRed"
        case .photoLibrary: return "systemPink"
        case .location, .locationAlways: return "systemGreen"
        case .contacts: return "systemOrange"
        case .calendar: return "systemPurple"
        case .reminders: return "systemTeal"
        case .notifications: return "systemYellow"
        case .healthKit: return "systemRed"
        case .motion: return "systemCyan"
        case .bluetooth: return "systemIndigo"
        case .speechRecognition: return "systemMint"
        case .faceID: return "systemGray"
        case .tracking: return "systemBrown"
        case .mediaLibrary: return "systemPink"
        }
    }
    
    // MARK: - 권한 설명
    /// 권한이 필요한 이유를 설명하는 텍스트
    public var usageDescription: String {
        switch self {
        case .camera:
            return "사진 및 동영상 촬영을 위해 카메라 접근이 필요합니다."
        case .microphone:
            return "음성 녹음 및 영상 통화를 위해 마이크 접근이 필요합니다."
        case .photoLibrary:
            return "사진 선택 및 저장을 위해 사진 라이브러리 접근이 필요합니다."
        case .location:
            return "현재 위치 기반 서비스를 위해 위치 정보가 필요합니다."
        case .locationAlways:
            return "백그라운드에서도 위치 추적을 위해 항상 위치 접근이 필요합니다."
        case .contacts:
            return "연락처 동기화 및 친구 찾기를 위해 연락처 접근이 필요합니다."
        case .calendar:
            return "일정 추가 및 관리를 위해 캘린더 접근이 필요합니다."
        case .reminders:
            return "할 일 관리를 위해 미리알림 접근이 필요합니다."
        case .notifications:
            return "중요한 업데이트와 알림을 받기 위해 알림 권한이 필요합니다."
        case .healthKit:
            return "건강 데이터 기록 및 분석을 위해 건강 앱 접근이 필요합니다."
        case .motion:
            return "걸음 수 및 활동 추적을 위해 동작 데이터 접근이 필요합니다."
        case .bluetooth:
            return "주변 기기 연결을 위해 블루투스 접근이 필요합니다."
        case .speechRecognition:
            return "음성 명령 인식을 위해 음성 인식 접근이 필요합니다."
        case .faceID:
            return "보안 인증을 위해 Face ID 사용이 필요합니다."
        case .tracking:
            return "맞춤형 광고 및 분석을 위해 앱 추적 권한이 필요합니다."
        case .mediaLibrary:
            return "음악 재생 및 플레이리스트 접근을 위해 미디어 라이브러리 접근이 필요합니다."
        }
    }
    
    // MARK: - 필수 권한 여부
    /// 앱 핵심 기능에 필수적인 권한인지 여부
    public var isEssential: Bool {
        switch self {
        case .camera, .microphone, .notifications:
            return true
        default:
            return false
        }
    }
    
    // MARK: - PermissionKit 키 변환
    /// iOS 26 PermissionKit의 PermissionKey로 변환
    public var permissionKey: PermissionKey {
        switch self {
        case .camera: return .camera
        case .microphone: return .microphone
        case .photoLibrary: return .photoLibrary
        case .location: return .locationWhenInUse
        case .locationAlways: return .locationAlways
        case .contacts: return .contacts
        case .calendar: return .calendar
        case .reminders: return .reminders
        case .notifications: return .notifications
        case .healthKit: return .healthKit
        case .motion: return .motion
        case .bluetooth: return .bluetooth
        case .speechRecognition: return .speechRecognition
        case .faceID: return .faceID
        case .tracking: return .appTracking
        case .mediaLibrary: return .mediaLibrary
        }
    }
}

// MARK: - 권한 그룹
/// 관련 권한들을 그룹으로 묶어서 관리
public enum PermissionGroup: String, CaseIterable, Identifiable {
    case essential = "필수 권한"
    case media = "미디어"
    case location = "위치"
    case personal = "개인 정보"
    case device = "기기 기능"
    case privacy = "개인정보 보호"
    
    public var id: String { rawValue }
    
    /// 그룹에 속하는 권한 타입들
    public var permissions: [PermissionType] {
        switch self {
        case .essential:
            return [.camera, .microphone, .notifications]
        case .media:
            return [.photoLibrary, .mediaLibrary]
        case .location:
            return [.location, .locationAlways]
        case .personal:
            return [.contacts, .calendar, .reminders, .healthKit]
        case .device:
            return [.bluetooth, .motion, .speechRecognition, .faceID]
        case .privacy:
            return [.tracking]
        }
    }
    
    /// 그룹 아이콘
    public var iconName: String {
        switch self {
        case .essential: return "star.fill"
        case .media: return "photo.stack.fill"
        case .location: return "map.fill"
        case .personal: return "person.fill"
        case .device: return "iphone"
        case .privacy: return "lock.shield.fill"
        }
    }
}
