//
//  DevicePairApp.swift
//  DevicePair
//
//  앱 진입점 - AccessorySetupKit을 활용한 기기 페어링 앱
//

import SwiftUI

// MARK: - 앱 진입점

/// DevicePair 앱의 메인 진입점
/// 액세서리 세션 매니저를 환경 객체로 주입
@main
struct DevicePairApp: App {
    
    /// 앱 전역에서 사용되는 액세서리 세션 매니저
    @StateObject private var sessionManager = AccessorySessionManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionManager)
        }
    }
}
