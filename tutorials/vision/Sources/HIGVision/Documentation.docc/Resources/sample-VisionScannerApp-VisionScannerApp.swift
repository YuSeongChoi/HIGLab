//
//  VisionScannerApp.swift
//  VisionScanner
//
//  Vision 프레임워크 샘플 앱 - 메인 엔트리 포인트
//

import SwiftUI

/// VisionScanner 앱의 메인 엔트리 포인트
@main
struct VisionScannerApp: App {
    
    /// Vision 매니저 (앱 전체에서 공유)
    @StateObject private var visionManager = VisionManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(visionManager)
        }
    }
}
