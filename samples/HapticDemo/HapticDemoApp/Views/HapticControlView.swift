// HapticControlView.swift
// HapticDemo - Core Haptics 샘플
// 햅틱 컨트롤 뷰 - 실시간 햅틱 제어 및 테스트

import SwiftUI

// MARK: - 햅틱 컨트롤 뷰
struct HapticControlView: View {
    @EnvironmentObject var hapticManager: HapticEngineManager
    
    // 일시적 햅틱 파라미터
    @State private var transientIntensity: Float = 0.8
    @State private var transientSharpness: Float = 0.5
    
    // 연속 햅틱 파라미터
    @State private var continuousIntensity: Float = 0.6
    @State private var continuousSharpness: Float = 0.5
    @State private var continuousDuration: Float = 0.5
    
    // 연속 재생 상태
    @State private var isContinuousPlaying: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 상태 표시
                    statusCard
                    
                    // 빠른 테스트 버튼
                    quickTestSection
                    
                    // 일시적 햅틱 컨트롤
                    transientControlSection
                    
                    // 연속 햅틱 컨트롤
                    continuousControlSection
                    
                    // 인터랙티브 패드
                    interactivePadSection
                }
                .padding()
            }
            .navigationTitle("햅틱 컨트롤")
        }
    }
    
    // MARK: - 상태 카드
    private var statusCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("엔진 상태")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 10, height: 10)
                    
                    Text(hapticManager.state.rawValue)
                        .font(.headline)
                }
            }
            
            Spacer()
            
            if let patternName = hapticManager.currentPatternName {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("재생 중")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(patternName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var statusColor: Color {
        switch hapticManager.state {
        case .ready: return .green
        case .playing: return .blue
        case .stopped: return .orange
        case .error: return .red
        case .notInitialized: return .gray
        }
    }
    
    // MARK: - 빠른 테스트 섹션
    private var quickTestSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("빠른 테스트")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                QuickTestButton(
                    title: "약하게",
                    icon: "hand.point.up",
                    color: .green
                ) {
                    hapticManager.playTransientHaptic(intensity: 0.3, sharpness: 0.3)
                }
                
                QuickTestButton(
                    title: "보통",
                    icon: "hand.tap",
                    color: .blue
                ) {
                    hapticManager.playTransientHaptic(intensity: 0.6, sharpness: 0.5)
                }
                
                QuickTestButton(
                    title: "강하게",
                    icon: "hand.tap.fill",
                    color: .purple
                ) {
                    hapticManager.playTransientHaptic(intensity: 1.0, sharpness: 0.8)
                }
                
                QuickTestButton(
                    title: "부드럽게",
                    icon: "cloud.fill",
                    color: .cyan
                ) {
                    hapticManager.playTransientHaptic(intensity: 0.7, sharpness: 0.1)
                }
                
                QuickTestButton(
                    title: "날카롭게",
                    icon: "bolt.fill",
                    color: .orange
                ) {
                    hapticManager.playTransientHaptic(intensity: 0.7, sharpness: 1.0)
                }
                
                QuickTestButton(
                    title: "연속",
                    icon: "waveform",
                    color: .pink
                ) {
                    hapticManager.playContinuousHaptic(intensity: 0.5, sharpness: 0.5, duration: 0.3)
                }
            }
        }
    }
    
    // MARK: - 일시적 햅틱 컨트롤 섹션
    private var transientControlSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.orange)
                Text("일시적 햅틱 (Transient)")
                    .font(.headline)
            }
            
            VStack(spacing: 12) {
                // 강도 슬라이더
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("강도")
                            .font(.subheadline)
                        Spacer()
                        Text("\(Int(transientIntensity * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "speaker.fill")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        
                        Slider(value: $transientIntensity, in: 0...1)
                            .tint(.orange)
                        
                        Image(systemName: "speaker.wave.3.fill")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                
                // 선명도 슬라이더
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("선명도")
                            .font(.subheadline)
                        Spacer()
                        Text("\(Int(transientSharpness * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "circle.fill")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        
                        Slider(value: $transientSharpness, in: 0...1)
                            .tint(.orange)
                        
                        Image(systemName: "triangle.fill")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                
                // 재생 버튼
                Button {
                    hapticManager.playTransientHaptic(
                        intensity: transientIntensity,
                        sharpness: transientSharpness
                    )
                } label: {
                    Label("일시적 햅틱 재생", systemImage: "bolt.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - 연속 햅틱 컨트롤 섹션
    private var continuousControlSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "waveform")
                    .foregroundColor(.green)
                Text("연속 햅틱 (Continuous)")
                    .font(.headline)
            }
            
            VStack(spacing: 12) {
                // 강도 슬라이더
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("강도")
                            .font(.subheadline)
                        Spacer()
                        Text("\(Int(continuousIntensity * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $continuousIntensity, in: 0...1)
                        .tint(.green)
                }
                
                // 선명도 슬라이더
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("선명도")
                            .font(.subheadline)
                        Spacer()
                        Text("\(Int(continuousSharpness * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $continuousSharpness, in: 0...1)
                        .tint(.green)
                }
                
                // 지속 시간 슬라이더
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("지속 시간")
                            .font(.subheadline)
                        Spacer()
                        Text(String(format: "%.2f초", continuousDuration))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $continuousDuration, in: 0.1...2)
                        .tint(.green)
                }
                
                // 재생/중지 버튼
                HStack(spacing: 12) {
                    Button {
                        hapticManager.playContinuousHaptic(
                            intensity: continuousIntensity,
                            sharpness: continuousSharpness,
                            duration: TimeInterval(continuousDuration)
                        )
                    } label: {
                        Label("재생", systemImage: "play.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button {
                        hapticManager.stopCurrentPlayback()
                    } label: {
                        Image(systemName: "stop.fill")
                            .font(.headline)
                            .padding()
                            .background(Color(.tertiarySystemFill))
                            .foregroundColor(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - 인터랙티브 패드 섹션
    private var interactivePadSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "hand.draw.fill")
                    .foregroundColor(.purple)
                Text("인터랙티브 패드")
                    .font(.headline)
            }
            
            Text("패드를 터치하여 위치에 따른 햅틱을 느껴보세요")
                .font(.caption)
                .foregroundColor(.secondary)
            
            InteractiveHapticPad { intensity, sharpness in
                hapticManager.playTransientHaptic(
                    intensity: intensity,
                    sharpness: sharpness
                )
            }
        }
    }
}

// MARK: - 빠른 테스트 버튼
struct QuickTestButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - 인터랙티브 햅틱 패드
struct InteractiveHapticPad: View {
    let onTouch: (Float, Float) -> Void
    
    @State private var touchLocation: CGPoint?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경 그라데이션
                LinearGradient(
                    colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // 그리드 라인
                VStack(spacing: 0) {
                    ForEach(0..<5) { _ in
                        Divider()
                        Spacer()
                    }
                }
                
                HStack(spacing: 0) {
                    ForEach(0..<5) { _ in
                        Divider()
                        Spacer()
                    }
                }
                
                // 축 레이블
                VStack {
                    Text("선명도 ↑")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("선명도 ↓")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
                
                HStack {
                    Text("강도 ←")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(-90))
                    Spacer()
                    Text("강도 →")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(-90))
                }
                .padding(.horizontal, 8)
                
                // 터치 위치 표시
                if let location = touchLocation {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 40, height: 40)
                        .shadow(color: .purple.opacity(0.5), radius: 10)
                        .position(location)
                }
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let location = value.location
                        touchLocation = location
                        
                        // X축: 강도 (0~1)
                        let intensity = Float(max(0, min(1, location.x / geometry.size.width)))
                        // Y축: 선명도 (상단이 1, 하단이 0)
                        let sharpness = Float(max(0, min(1, 1 - location.y / 200)))
                        
                        onTouch(intensity, sharpness)
                    }
                    .onEnded { _ in
                        touchLocation = nil
                    }
            )
        }
        .frame(height: 200)
    }
}

#Preview {
    HapticControlView()
        .environmentObject(HapticEngineManager())
}
