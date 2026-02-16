import SwiftUI

/// 매칭 성공 애니메이션이 포함된 결과 뷰
struct MatchedSongView: View {
    let song: Song
    @State private var isAnimating = false
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack(spacing: 20) {
            // 앨범 아트 (애니메이션)
            ArtworkView(song: song, size: .large)
                .scaleEffect(scale)
                .opacity(opacity)
            
            // 곡 정보 (페이드인)
            VStack(spacing: 8) {
                Text(song.title)
                    .font(.title2.bold())
                
                Text(song.artist)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .opacity(opacity)
            
            // 액션 버튼
            SongActionButtons(song: song)
                .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

/// 인식 중 애니메이션
struct ListeningAnimationView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { index in
                Circle()
                    .stroke(lineWidth: 2)
                    .foregroundStyle(.blue.opacity(0.5))
                    .scaleEffect(isAnimating ? 2 : 0.5)
                    .opacity(isAnimating ? 0 : 1)
                    .animation(
                        .easeOut(duration: 1.5)
                        .repeatForever(autoreverses: false)
                        .delay(Double(index) * 0.5),
                        value: isAnimating
                    )
            }
            
            Image(systemName: "waveform")
                .font(.system(size: 40))
                .foregroundStyle(.blue)
        }
        .frame(width: 150, height: 150)
        .onAppear { isAnimating = true }
    }
}
