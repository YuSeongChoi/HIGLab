//
//  ARFurnitureApp.swift
//  ARFurniture
//
//  AR 가구 배치 앱 메인 엔트리 포인트
//

import SwiftUI

/// 앱 메인 진입점
@main
struct ARFurnitureApp: App {
    
    /// AR 매니저 (앱 전역 상태)
    @StateObject private var arManager = ARManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(arManager)
                .preferredColorScheme(.dark)  // AR 앱은 다크 모드가 적합
        }
    }
}
