// DirectShareApp.swift
// DirectShare - Wi-Fi Aware 직접 파일 공유
// 앱 진입점 및 환경 설정

import SwiftUI

/// DirectShare 메인 앱
/// Wi-Fi Aware를 사용하여 AP 없이 직접 파일을 공유합니다
@main
struct DirectShareApp: App {
    /// Wi-Fi Aware 매니저 (앱 전체에서 공유)
    @State private var wifiAwareManager = WiFiAwareManager()
    
    /// 파일 전송 서비스
    @State private var transferService = FileTransferService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(wifiAwareManager)
                .environment(transferService)
                .onAppear {
                    // 전송 서비스에 Wi-Fi Aware 매니저 연결
                    transferService.setWiFiAwareManager(wifiAwareManager)
                }
        }
    }
}

// MARK: - 앱 상수

enum AppConstants {
    /// 서비스 타입 (Wi-Fi Aware 서비스 식별자)
    static let serviceType = "_directshare._wifiaware"
    
    /// 앱 버전
    static let appVersion = "1.0.0"
    
    /// 연결 타임아웃 (초)
    static let connectionTimeout: TimeInterval = 30
    
    /// 핑 간격 (초)
    static let pingInterval: TimeInterval = 10
    
    /// 피어 만료 시간 (마지막 확인 후 제거까지)
    static let peerExpirationTime: TimeInterval = 60
    
    /// 최대 동시 전송 수
    static let maxConcurrentTransfers = 3
    
    /// 청크 크기 (대용량 파일 전송 시)
    static let chunkSize = 64 * 1024  // 64KB
    
    /// 보안 연결 사용 여부
    static let useSecureConnection = true
}

// MARK: - 디바이스 정보

enum DeviceInfo {
    /// 현재 디바이스 이름
    static var deviceName: String {
        #if os(iOS)
        return UIDevice.current.name
        #elseif os(macOS)
        return Host.current().localizedName ?? "Mac"
        #else
        return "Unknown Device"
        #endif
    }
    
    /// 디바이스 모델
    static var deviceModel: String {
        #if os(iOS)
        return UIDevice.current.model
        #elseif os(macOS)
        return "Mac"
        #else
        return "Unknown"
        #endif
    }
    
    /// OS 버전
    static var osVersion: String {
        #if os(iOS)
        return UIDevice.current.systemVersion
        #elseif os(macOS)
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        #else
        return "Unknown"
        #endif
    }
    
    /// TXT 레코드용 메타데이터
    static var txtRecord: [String: String] {
        [
            "name": deviceName,
            "model": deviceModel,
            "os": osVersion,
            "app": AppConstants.appVersion
        ]
    }
}
