// WakeUpApp.swift
// WakeUp - AlarmKit 샘플 프로젝트
// 앱 진입점 및 Scene 구성

import SwiftUI
import AlarmKit

// MARK: - 앱 진입점

/// WakeUp 앱의 메인 진입점
/// iOS 26 AlarmKit을 활용한 시스템 알람 앱
@main
struct WakeUpApp: App {
    
    // MARK: - 상태
    
    /// 알람 관리자 (앱 전역에서 공유)
    @State private var alarmManager = AlarmManager()
    
    /// 앱 델리게이트 어댑터
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // MARK: - 본문
    
    var body: some Scene {
        WindowGroup {
            AlarmListView()
                .environment(alarmManager)
                .onAppear {
                    setupAlarmKit()
                }
        }
    }
    
    // MARK: - AlarmKit 설정
    
    /// AlarmKit 초기화 및 권한 요청
    private func setupAlarmKit() {
        Task {
            await alarmManager.requestAuthorization()
            await alarmManager.loadAlarms()
        }
    }
}

// MARK: - App Delegate

/// 앱 생명주기 및 AlarmKit 이벤트 처리를 위한 델리게이트
final class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // AlarmKit 알림 카테고리 등록
        registerAlarmNotificationCategories()
        return true
    }
    
    /// 알람 관련 알림 카테고리 등록
    private func registerAlarmNotificationCategories() {
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "스누즈",
            options: []
        )
        
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS_ACTION",
            title: "끄기",
            options: [.destructive]
        )
        
        let alarmCategory = UNNotificationCategory(
            identifier: "ALARM_CATEGORY",
            actions: [snoozeAction, dismissAction],
            intentIdentifiers: [],
            options: [.customDismissAction, .allowAnnouncement]
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([alarmCategory])
    }
}

// MARK: - 환경 키

/// AlarmManager 환경 키
extension EnvironmentValues {
    @Entry var alarmManager: AlarmManager = AlarmManager()
}
