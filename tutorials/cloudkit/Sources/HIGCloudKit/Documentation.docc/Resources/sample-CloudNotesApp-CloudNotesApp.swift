// CloudNotesApp.swift
// CloudNotes - 앱 진입점
//
// @main 앱 구조체 및 초기화 로직

import SwiftUI
import CloudKit

// MARK: - CloudNotesApp

/// CloudNotes 앱 메인 구조체
@main
struct CloudNotesApp: App {
    
    // MARK: - 속성
    
    /// CloudKit 관리자 (환경 객체로 전달)
    @StateObject private var cloudKitManager = CloudKitManager.shared
    
    /// 네트워크 모니터 (환경 객체로 전달)
    @StateObject private var networkMonitor = NetworkMonitor.shared
    
    /// 앱 델리게이트 연결 (푸시 알림 처리용)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cloudKitManager)
                .environmentObject(networkMonitor)
                .task {
                    // 앱 시작 시 노트 로드
                    await loadInitialData()
                }
        }
    }
    
    // MARK: - 초기화
    
    /// 초기 데이터 로드
    private func loadInitialData() async {
        do {
            try await cloudKitManager.fetchNotes()
        } catch {
            print("❌ 초기 데이터 로드 실패: \(error)")
        }
    }
}

// MARK: - AppDelegate

/// UIKit AppDelegate - 푸시 알림 처리
class AppDelegate: NSObject, UIApplicationDelegate {
    
    /// 앱 실행 완료
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // 원격 알림 등록 (CloudKit 동기화용)
        application.registerForRemoteNotifications()
        return true
    }
    
    /// 원격 알림 등록 성공
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        print("✅ 푸시 알림 등록 성공")
    }
    
    /// 원격 알림 등록 실패
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ 푸시 알림 등록 실패: \(error)")
    }
    
    /// 원격 알림 수신 (백그라운드/포그라운드)
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        // CloudKit 알림인지 확인
        guard let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) else {
            completionHandler(.noData)
            return
        }
        
        print("📥 CloudKit 알림 수신: \(notification.notificationType)")
        
        // 변경사항 처리
        Task { @MainActor in
            await CloudKitManager.shared.handleRemoteNotification()
            completionHandler(.newData)
        }
    }
}

// MARK: - 환경 값

/// 커스텀 환경 키
private struct CloudKitManagerKey: EnvironmentKey {
    static let defaultValue = CloudKitManager.shared
}

extension EnvironmentValues {
    /// CloudKit 관리자 환경 값
    var cloudKitManager: CloudKitManager {
        get { self[CloudKitManagerKey.self] }
        set { self[CloudKitManagerKey.self] = newValue }
    }
}
