import SwiftUI
import SpriteKit

@main
struct SpaceBlastApp: App {
    var body: some Scene {
        WindowGroup {
            GameContainerView()
        }
    }
}

struct GameContainerView: View {
    @State private var isPlaying = false
    @State private var score = 0
    @State private var highScore = UserDefaults.standard.integer(forKey: "highScore")
    
    var body: some View {
        ZStack {
            if isPlaying {
                GameView(score: $score, isPlaying: $isPlaying)
                    .ignoresSafeArea()
                
                // HUD
                VStack {
                    HStack {
                        Text("점수: \(score)")
                            .font(.headline)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                        
                        Spacer()
                        
                        Button {
                            isPlaying = false
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
            } else {
                // 메인 메뉴
                MenuView(
                    highScore: highScore,
                    onStart: { isPlaying = true }
                )
            }
        }
        .onChange(of: isPlaying) {
            if !isPlaying && score > highScore {
                highScore = score
                UserDefaults.standard.set(highScore, forKey: "highScore")
            }
        }
    }
}

// MARK: - Menu View
struct MenuView: View {
    let highScore: Int
    let onStart: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // 배경 별
            StarField()
            
            VStack(spacing: 40) {
                Text("🚀 SpaceBlast")
                    .font(.system(size: 48, weight: .black))
                    .foregroundStyle(.white)
                
                if highScore > 0 {
                    Text("최고 점수: \(highScore)")
                        .font(.title2)
                        .foregroundStyle(.yellow)
                }
                
                Button(action: onStart) {
                    Text("게임 시작")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
        }
    }
}

// MARK: - Star Field Background
struct StarField: View {
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<50, id: \.self) { _ in
                Circle()
                    .fill(.white)
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: CGFloat.random(in: 0...geo.size.height)
                    )
                    .opacity(Double.random(in: 0.3...1))
            }
        }
    }
}

#Preview {
    GameContainerView()
}
