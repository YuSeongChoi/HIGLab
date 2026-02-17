// ContentView.swift
// SpaceShooter - SpriteKit 2D 게임
// 메인 UI 뷰

import SwiftUI
import SpriteKit

/// 메인 콘텐츠 뷰
/// 게임 상태에 따라 메뉴, 게임, 일시정지, 게임오버 화면을 표시합니다.
struct ContentView: View {
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        ZStack {
            // 배경색 (우주 느낌의 진한 파랑)
            Color(red: 0.02, green: 0.02, blue: 0.1)
                .ignoresSafeArea()
            
            // 게임 씬 (항상 표시, 상태에 따라 동작)
            GameContainerView()
                .environmentObject(gameState)
            
            // 오버레이 UI
            overlayView
        }
    }
    
    /// 상태별 오버레이 뷰
    @ViewBuilder
    private var overlayView: some View {
        switch gameState.status {
        case .ready:
            MenuOverlayView()
                .transition(.opacity)
            
        case .playing:
            GameHUDView()
                .transition(.opacity)
            
        case .paused:
            PauseOverlayView()
                .transition(.opacity)
            
        case .gameOver:
            GameOverOverlayView()
                .transition(.opacity)
        }
    }
}

// MARK: - 게임 컨테이너 뷰

/// SpriteKit 게임 씬을 호스팅하는 뷰
struct GameContainerView: View {
    @EnvironmentObject var gameState: GameState
    
    /// 게임 씬 인스턴스
    @State private var gameScene: GameScene?
    
    var body: some View {
        GeometryReader { geometry in
            SpriteView(scene: getScene(size: geometry.size))
                .ignoresSafeArea()
        }
    }
    
    /// 게임 씬 가져오기 또는 생성
    private func getScene(size: CGSize) -> GameScene {
        if let scene = gameScene {
            return scene
        }
        
        let scene = GameScene(size: size)
        scene.scaleMode = .resizeFill
        scene.gameState = gameState
        
        DispatchQueue.main.async {
            self.gameScene = scene
        }
        
        return scene
    }
}

// MARK: - 메뉴 오버레이

/// 게임 시작 전 메뉴 화면
struct MenuOverlayView: View {
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // 타이틀
            VStack(spacing: 10) {
                Text("🚀")
                    .font(.system(size: 80))
                
                Text("SPACE SHOOTER")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("우주를 지켜라!")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            // 최고 점수 표시
            if gameState.highScore > 0 {
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                    Text("최고 점수: \(gameState.highScore)")
                        .foregroundColor(.yellow)
                }
                .font(.system(size: 18, weight: .semibold))
            }
            
            // 시작 버튼
            Button(action: {
                withAnimation {
                    gameState.startGame()
                }
            }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("게임 시작")
                }
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 50)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(30)
                .shadow(color: .blue.opacity(0.5), radius: 10)
            }
            
            // 조작 안내
            VStack(spacing: 8) {
                Text("🎮 조작법")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("화면을 터치하여 우주선 이동")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                
                Text("총알은 자동 발사")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.top, 30)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - 게임 HUD

/// 게임 플레이 중 표시되는 HUD
struct GameHUDView: View {
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        VStack {
            // 상단 HUD
            HStack {
                // 점수
                VStack(alignment: .leading, spacing: 4) {
                    Text("SCORE")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("\(gameState.score)")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // 웨이브
                VStack(spacing: 4) {
                    Text("WAVE")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("\(gameState.wave)")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.cyan)
                }
                
                Spacer()
                
                // 생명
                HStack(spacing: 4) {
                    ForEach(0..<gameState.lives, id: \.self) { _ in
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                    }
                    ForEach(0..<(GameState.maxLives - gameState.lives), id: \.self) { _ in
                        Image(systemName: "heart")
                            .foregroundColor(.red.opacity(0.3))
                    }
                }
                .font(.system(size: 18))
            }
            .padding(.horizontal, 20)
            .padding(.top, 50)
            
            Spacer()
            
            // 일시정지 버튼
            HStack {
                Spacer()
                
                Button(action: {
                    withAnimation {
                        gameState.pauseGame()
                    }
                }) {
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.trailing, 20)
                .padding(.bottom, 30)
            }
        }
    }
}

// MARK: - 일시정지 오버레이

/// 일시정지 화면
struct PauseOverlayView: View {
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        ZStack {
            // 반투명 배경
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("일시 정지")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                // 현재 상태 표시
                VStack(spacing: 10) {
                    HStack {
                        Text("점수:")
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(gameState.score)")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                    
                    HStack {
                        Text("웨이브:")
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(gameState.wave)")
                            .foregroundColor(.cyan)
                            .fontWeight(.bold)
                    }
                    
                    HStack {
                        Text("플레이 시간:")
                            .foregroundColor(.white.opacity(0.7))
                        Text(gameState.formattedPlayTime)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                }
                .font(.system(size: 18))
                
                // 버튼들
                VStack(spacing: 15) {
                    // 계속하기
                    Button(action: {
                        withAnimation {
                            gameState.resumeGame()
                        }
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("계속하기")
                        }
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 200)
                        .padding(.vertical, 15)
                        .background(Color.green)
                        .cornerRadius(25)
                    }
                    
                    // 메뉴로
                    Button(action: {
                        withAnimation {
                            gameState.resetGame()
                        }
                    }) {
                        HStack {
                            Image(systemName: "house.fill")
                            Text("메뉴로")
                        }
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 200)
                        .padding(.vertical, 15)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(25)
                    }
                }
            }
        }
    }
}

// MARK: - 게임오버 오버레이

/// 게임오버 화면
struct GameOverOverlayView: View {
    @EnvironmentObject var gameState: GameState
    
    /// 최고 점수 갱신 여부
    var isNewHighScore: Bool {
        gameState.score >= gameState.highScore && gameState.score > 0
    }
    
    var body: some View {
        ZStack {
            // 반투명 배경
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                // 게임오버 타이틀
                Text("GAME OVER")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.red)
                
                // 최고 점수 갱신 시
                if isNewHighScore {
                    Text("🎉 새로운 최고 점수! 🎉")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.yellow)
                }
                
                // 결과 표시
                VStack(spacing: 15) {
                    ResultRow(label: "최종 점수", value: "\(gameState.score)")
                    ResultRow(label: "최고 점수", value: "\(gameState.highScore)")
                    ResultRow(label: "도달 웨이브", value: "\(gameState.wave)")
                    ResultRow(label: "처치 수", value: "\(gameState.enemiesDefeated)")
                    ResultRow(label: "플레이 시간", value: gameState.formattedPlayTime)
                }
                .padding(.vertical, 20)
                
                // 버튼들
                VStack(spacing: 15) {
                    // 다시하기
                    Button(action: {
                        withAnimation {
                            ScoreManager.shared.resetAll()
                            gameState.startGame()
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("다시 도전")
                        }
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 200)
                        .padding(.vertical, 15)
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                    }
                    
                    // 메뉴로
                    Button(action: {
                        withAnimation {
                            ScoreManager.shared.resetAll()
                            gameState.resetGame()
                        }
                    }) {
                        HStack {
                            Image(systemName: "house.fill")
                            Text("메뉴로")
                        }
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                        .frame(width: 200)
                        .padding(.vertical, 15)
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(25)
                    }
                }
            }
        }
    }
}

/// 결과 행 컴포넌트
struct ResultRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(value)
                .foregroundColor(.white)
                .fontWeight(.bold)
        }
        .font(.system(size: 18))
        .frame(width: 220)
    }
}

// MARK: - 프리뷰

#Preview {
    ContentView()
        .environmentObject(GameState())
}
