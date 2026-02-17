// ServiceType.swift
// PeerChat - MultipeerConnectivity 기반 P2P 채팅
// 서비스 타입 및 상수 정의

import Foundation

/// MultipeerConnectivity 서비스 설정
enum PeerChatService {
    /// 서비스 타입 (Bonjour 서비스 식별자)
    /// 1-15자, 소문자, 숫자, 하이픈만 허용
    static let serviceType = "peerchat-hig"
    
    /// 발견 정보 키
    enum DiscoveryInfoKey {
        static let displayName = "displayName"
        static let deviceType = "deviceType"
        static let appVersion = "appVersion"
        static let sessionID = "sessionID"
    }
    
    /// 현재 기기 타입
    static var currentDeviceType: String {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            return "iPad"
        } else {
            return "iPhone"
        }
        #elseif os(macOS)
        return "Mac"
        #else
        return "Unknown"
        #endif
    }
    
    /// 앱 버전
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    /// 발견 정보 생성
    static func makeDiscoveryInfo(displayName: String, sessionID: String) -> [String: String] {
        [
            DiscoveryInfoKey.displayName: displayName,
            DiscoveryInfoKey.deviceType: currentDeviceType,
            DiscoveryInfoKey.appVersion: appVersion,
            DiscoveryInfoKey.sessionID: sessionID
        ]
    }
}

/// 파일 공유 지원 타입
enum SupportedFileType: String, CaseIterable {
    case image = "public.image"
    case pdf = "com.adobe.pdf"
    case text = "public.plain-text"
    case data = "public.data"
    
    /// 파일 확장자에서 타입 추론
    static func from(extension ext: String) -> SupportedFileType {
        switch ext.lowercased() {
        case "jpg", "jpeg", "png", "gif", "heic", "webp":
            return .image
        case "pdf":
            return .pdf
        case "txt", "md", "swift", "json":
            return .text
        default:
            return .data
        }
    }
    
    /// MIME 타입
    var mimeType: String {
        switch self {
        case .image:
            return "image/*"
        case .pdf:
            return "application/pdf"
        case .text:
            return "text/plain"
        case .data:
            return "application/octet-stream"
        }
    }
    
    /// 아이콘 이름
    var iconName: String {
        switch self {
        case .image:
            return "photo"
        case .pdf:
            return "doc.richtext"
        case .text:
            return "doc.text"
        case .data:
            return "doc"
        }
    }
}

/// 에러 타입 정의
enum PeerChatError: LocalizedError {
    case sessionNotFound
    case peerNotConnected
    case encodingFailed
    case decodingFailed
    case fileTooLarge(maxSize: Int)
    case sendFailed(underlying: Error)
    case connectionFailed
    case invitationTimeout
    
    var errorDescription: String? {
        switch self {
        case .sessionNotFound:
            return "세션을 찾을 수 없습니다"
        case .peerNotConnected:
            return "피어가 연결되어 있지 않습니다"
        case .encodingFailed:
            return "메시지 인코딩에 실패했습니다"
        case .decodingFailed:
            return "메시지 디코딩에 실패했습니다"
        case .fileTooLarge(let maxSize):
            return "파일 크기가 \(maxSize / 1024 / 1024)MB를 초과합니다"
        case .sendFailed(let error):
            return "전송 실패: \(error.localizedDescription)"
        case .connectionFailed:
            return "연결에 실패했습니다"
        case .invitationTimeout:
            return "초대 시간이 만료되었습니다"
        }
    }
}
