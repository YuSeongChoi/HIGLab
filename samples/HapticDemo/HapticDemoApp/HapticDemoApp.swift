// HapticDemoApp.swift
// HapticDemo - Core Haptics 샘플
// 앱 진입점

import SwiftUI

@main
struct HapticDemoApp: App {
    // 앱 전체에서 공유할 햅틱 엔진 매니저
    @StateObject private var hapticManager = HapticEngineManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(hapticManager)
        }
    }
}
