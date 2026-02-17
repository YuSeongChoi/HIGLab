import SwiftUI

// MARK: - ListeningView
// 듣는 중 애니메이션을 표시하는 뷰

struct ListeningView: View {
    // MARK: - 애니메이션 상태
    @State private var isAnimating = false
    @State private var wavePhase: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 24) {
            // MARK: - 파형 애니메이션
            WaveformView(phase: wavePhase)
                .frame(height: 100)
                .padding(.horizontal, 40)
            
            // MARK: - 펄스 원
            ZStack {
                // 외부 펄스
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(lineWidth: 2)
                        .foregroundStyle(.blue.opacity(0.3))
                        .scaleEffect(isAnimating ? 2 : 1)
                        .opacity(isAnimating ? 0 : 0.8)
                        .animation(
                            .easeOut(duration: 1.5)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.5),
                            value: isAnimating
                        )
                }
                
                // 중앙 원
                Circle()
                    .fill(.blue)
                    .frame(width: 80, height: 80)
                    .overlay {
                        Image(systemName: "ear.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.white)
                    }
            }
            .frame(width: 160, height: 160)
            
            // MARK: - 텍스트
            Text("듣는 중...")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("주변 음악을 인식하고 있습니다")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .onAppear {
            isAnimating = true
            // 파형 애니메이션 시작
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                wavePhase = .pi * 2
            }
        }
    }
}

// MARK: - WaveformView
// 오디오 파형 시각화

struct WaveformView: View {
    let phase: CGFloat
    let barCount = 30
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<barCount, id: \.self) { index in
                WaveBar(
                    height: calculateHeight(for: index),
                    delay: Double(index) * 0.05
                )
            }
        }
    }
    
    // 각 바의 높이 계산 (사인파 기반)
    private func calculateHeight(for index: Int) -> CGFloat {
        let progress = CGFloat(index) / CGFloat(barCount)
        let wave = sin(progress * .pi * 4 + phase)
        return 0.3 + (wave + 1) / 2 * 0.7 // 0.3 ~ 1.0 범위
    }
}

// MARK: - WaveBar
// 개별 파형 바

struct WaveBar: View {
    let height: CGFloat
    let delay: Double
    
    @State private var isAnimating = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .frame(width: 4)
            .frame(height: 60 * height)
            .animation(
                .easeInOut(duration: 0.3)
                .delay(delay),
                value: height
            )
    }
}

// MARK: - Preview

#Preview {
    ListeningView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
}
