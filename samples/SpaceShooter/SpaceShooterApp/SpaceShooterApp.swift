// SpaceShooterApp.swift
// SpaceShooter - SpriteKit 2D 게임
// 앱 엔트리 포인트

import SwiftUI

/// SpaceShooter 앱 메인 엔트리 포인트
/// SpriteKit 기반 2D 슈팅 게임
@main
struct SpaceShooterApp: App {
    /// 게임 상태 (앱 전체에서 공유)
    @StateObject private var gameState = GameState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameState)
                .preferredColorScheme(.dark)
        }
    }
}
