import SwiftUI

// MARK: - ListeningView
/// 듣는 중 상태를 표시하는 뷰
/// 오디오 파형, 펄스 애니메이션, 시간 표시 포함

struct ListeningView: View {
    // MARK: - 애니메이션 상태
    @State private var isAnimating = false
    @State private var wavePhase: CGFloat = 0
    @State private var elapsedTime: TimeInterval = 0
    
    // MARK: - 타이머
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 32) {
            // MARK: - 오디오 스펙트럼 시각화
            AudioSpectrumView(phase: wavePhase)
                .frame(height: 120)
                .padding(.horizontal, 30)
            
            // MARK: - 펄스 애니메이션
            ZStack {
                // 외부 펄스 링
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(lineWidth: 2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .opacity(0.3)
                        )
                        .scaleEffect(isAnimating ? 2.5 : 1)
                        .opacity(isAnimating ? 0 : 0.8)
                        .animation(
                            .easeOut(duration: 2)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.6),
                            value: isAnimating
                        )
                }
                
                // 중앙 원
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: .blue.opacity(0.3), radius: 15)
                    .overlay {
                        // 귀 아이콘 애니메이션
                        Image(systemName: "ear.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.white)
                            .symbolEffect(.pulse, isActive: isAnimating)
                    }
            }
            .frame(width: 200, height: 200)
            
            // MARK: - 텍스트 및 시간
            VStack(spacing: 8) {
                Text("듣는 중...")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("주변 음악을 인식하고 있습니다")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                // 경과 시간
                Text(timeString)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .monospacedDigit()
                    .padding(.top, 4)
            }
            
            // MARK: - 팁
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                
                Text("더 가까이 다가가면 인식률이 높아집니다")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
        }
        .onAppear {
            isAnimating = true
            startWaveAnimation()
        }
        .onDisappear {
            isAnimating = false
        }
        .onReceive(timer) { _ in
            elapsedTime += 0.1
        }
    }
    
    // MARK: - 경과 시간 문자열
    private var timeString: String {
        let seconds = Int(elapsedTime)
        return String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
    
    // MARK: - 파형 애니메이션
    private func startWaveAnimation() {
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            wavePhase = .pi * 2
        }
    }
}

// MARK: - AudioSpectrumView
/// 오디오 스펙트럼 시각화 뷰

struct AudioSpectrumView: View {
    let phase: CGFloat
    let barCount = 40
    
    @State private var randomHeights: [CGFloat] = []
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 2) {
                ForEach(0..<barCount, id: \.self) { index in
                    SpectrumBar(
                        height: calculateHeight(for: index, totalWidth: geometry.size.height),
                        index: index
                    )
                }
            }
        }
        .onAppear {
            generateRandomHeights()
        }
    }
    
    /// 각 바의 높이 계산 (여러 사인파 합성)
    private func calculateHeight(for index: Int, totalWidth: CGFloat) -> CGFloat {
        let progress = CGFloat(index) / CGFloat(barCount)
        
        // 여러 주파수의 사인파 합성
        let wave1 = sin(progress * .pi * 6 + phase)
        let wave2 = sin(progress * .pi * 3 + phase * 0.7) * 0.5
        let wave3 = sin(progress * .pi * 12 + phase * 1.5) * 0.25
        
        // 무작위 변동 추가
        let random = randomHeights.indices.contains(index) ? randomHeights[index] : 0.5
        
        // 0.2 ~ 1.0 범위로 정규화
        let combined = (wave1 + wave2 + wave3 + 1.75) / 3.5
        let withRandom = combined * 0.7 + random * 0.3
        
        return max(0.15, min(1.0, withRandom))
    }
    
    /// 무작위 높이 생성
    private func generateRandomHeights() {
        randomHeights = (0..<barCount).map { _ in
            CGFloat.random(in: 0.3...1.0)
        }
        
        // 주기적으로 업데이트
        Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.15)) {
                for i in randomHeights.indices {
                    randomHeights[i] = CGFloat.random(in: 0.3...1.0)
                }
            }
        }
    }
}

// MARK: - SpectrumBar
/// 개별 스펙트럼 바

struct SpectrumBar: View {
    let height: CGFloat
    let index: Int
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(barGradient)
            .frame(maxHeight: .infinity)
            .scaleEffect(y: height, anchor: .bottom)
    }
    
    /// 바 그라데이션 (위치에 따라 색상 변화)
    private var barGradient: LinearGradient {
        let progress = CGFloat(index) / 40.0
        
        return LinearGradient(
            colors: [
                Color(hue: 0.6 + progress * 0.2, saturation: 0.8, brightness: 0.9),
                Color(hue: 0.7 + progress * 0.2, saturation: 0.9, brightness: 1.0)
            ],
            startPoint: .bottom,
            endPoint: .top
        )
    }
}

// MARK: - CircularWaveView
/// 원형 파형 뷰 (대체 스타일)

struct CircularWaveView: View {
    let phase: CGFloat
    let waveCount = 4
    
    var body: some View {
        ZStack {
            ForEach(0..<waveCount, id: \.self) { index in
                WaveCircle(
                    phase: phase,
                    delay: Double(index) * 0.3,
                    amplitude: 1.0 - Double(index) * 0.2
                )
            }
        }
    }
}

struct WaveCircle: View {
    let phase: CGFloat
    let delay: Double
    let amplitude: Double
    
    var body: some View {
        Circle()
            .stroke(
                LinearGradient(
                    colors: [.blue.opacity(0.6), .purple.opacity(0.4)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 3
            )
            .scaleEffect(1 + sin(phase + CGFloat(delay)) * 0.1 * amplitude)
            .opacity(amplitude)
    }
}

// MARK: - 음량 인디케이터
/// 실시간 음량 표시 (미래 확장용)

struct VolumeIndicator: View {
    @State private var level: CGFloat = 0.5
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<10, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(barColor(for: index))
                    .frame(width: 3, height: 20)
                    .opacity(CGFloat(index) / 10 <= level ? 1 : 0.3)
            }
        }
    }
    
    private func barColor(for index: Int) -> Color {
        if index < 4 {
            return .green
        } else if index < 7 {
            return .yellow
        } else {
            return .red
        }
    }
}

// MARK: - Preview

#Preview("ListeningView") {
    ListeningView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
}

#Preview("AudioSpectrumView") {
    AudioSpectrumView(phase: 0)
        .frame(height: 100)
        .padding()
        .background(Color(.systemBackground))
}
