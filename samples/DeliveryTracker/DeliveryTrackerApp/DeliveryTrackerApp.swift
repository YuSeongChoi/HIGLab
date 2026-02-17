//
//  DeliveryTrackerApp.swift
//  DeliveryTracker
//
//  배달 추적 앱의 메인 진입점
//  ActivityKit을 활용한 Live Activity 데모 앱입니다.
//

import SwiftUI

/// 앱의 메인 진입점
/// @main 어트리뷰트는 앱의 시작점을 나타냅니다.
@main
struct DeliveryTrackerApp: App {
    
    /// 앱의 씬 구성
    /// WindowGroup은 앱의 메인 윈도우를 정의합니다.
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
