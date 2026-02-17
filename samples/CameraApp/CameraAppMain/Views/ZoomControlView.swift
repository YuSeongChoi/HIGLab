import SwiftUI

// MARK: - 줌 컨트롤 뷰
// 줌 배율 선택 버튼과 슬라이더를 제공합니다.
// HIG: 줌 조작은 직관적이어야 하며, 현재 배율을 명확히 표시합니다.

struct ZoomControlView: View {
    
    // MARK: - Properties
    
    /// 현재 줌 배율
    @Binding var currentZoom: CGFloat
    
    /// 줌 범위
    let zoomRange: ClosedRange<CGFloat>
    
    /// 줌 프리셋 (0.5x, 1x, 2x, 3x 등)
    let presets: [CGFloat]
    
    /// 줌 변경 핸들러
    var onZoomChange: ((CGFloat) -> Void)?
    
    /// 프리셋 선택 핸들러
    var onPresetSelected: ((CGFloat) -> Void)?
    
    // MARK: - State
    
    /// 슬라이더 표시 여부
    @State private var showSlider = false
    
    /// 슬라이더 자동 숨김 타이머
    @State private var hideSliderTask: Task<Void, Never>?
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 12) {
            // 줌 슬라이더 (확장 시)
            if showSlider {
                zoomSlider
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // 줌 프리셋 버튼들
            presetButtons
        }
        .animation(.easeInOut(duration: 0.2), value: showSlider)
    }
    
    // MARK: - Preset Buttons
    
    private var presetButtons: some View {
        HStack(spacing: 0) {
            ForEach(presets, id: \.self) { preset in
                ZoomPresetButton(
                    zoom: preset,
                    isSelected: isPresetSelected(preset),
                    action: {
                        selectPreset(preset)
                    }
                )
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.4))
        )
    }
    
    // MARK: - Zoom Slider
    
    private var zoomSlider: some View {
        VStack(spacing: 8) {
            // 현재 배율 표시
            Text(String(format: "%.1fx", currentZoom))
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
            
            // 슬라이더
            HStack(spacing: 16) {
                // 최소 줌
                Text(String(format: "%.1fx", zoomRange.lowerBound))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
                
                // 슬라이더
                Slider(
                    value: $currentZoom,
                    in: zoomRange,
                    onEditingChanged: { editing in
                        if editing {
                            cancelHideTimer()
                        } else {
                            scheduleHideSlider()
                        }
                        onZoomChange?(currentZoom)
                    }
                )
                .tint(.yellow)
                
                // 최대 줌
                Text(String(format: "%.1fx", zoomRange.upperBound))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.6))
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - Helpers
    
    /// 프리셋이 현재 선택된 상태인지 확인
    private func isPresetSelected(_ preset: CGFloat) -> Bool {
        // 현재 줌이 프리셋 근처(±0.1)인지 확인
        abs(currentZoom - preset) < 0.1
    }
    
    /// 프리셋 선택
    private func selectPreset(_ preset: CGFloat) {
        // 같은 프리셋 다시 탭하면 슬라이더 토글
        if isPresetSelected(preset) {
            withAnimation {
                showSlider.toggle()
            }
            if showSlider {
                scheduleHideSlider()
            }
        } else {
            currentZoom = preset
            onPresetSelected?(preset)
        }
    }
    
    /// 슬라이더 자동 숨김 예약
    private func scheduleHideSlider() {
        cancelHideTimer()
        hideSliderTask = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3초
            if !Task.isCancelled {
                await MainActor.run {
                    withAnimation {
                        showSlider = false
                    }
                }
            }
        }
    }
    
    /// 숨김 타이머 취소
    private func cancelHideTimer() {
        hideSliderTask?.cancel()
        hideSliderTask = nil
    }
}

// MARK: - Zoom Preset Button

/// 줌 프리셋 버튼 (0.5x, 1x, 2x 등)
struct ZoomPresetButton: View {
    
    let zoom: CGFloat
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(zoomText)
                .font(.system(size: isSelected ? 14 : 12, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .yellow : .white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(isSelected ? Color.yellow.opacity(0.2) : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }
    
    /// 배율 텍스트 (0.5x, 1x, 2x 등)
    private var zoomText: String {
        if zoom < 1 {
            // 0.5x
            return String(format: ".%dx", Int(zoom * 10))
        } else if zoom == floor(zoom) {
            // 1x, 2x, 3x
            return "\(Int(zoom))x"
        } else {
            // 1.5x 등
            return String(format: "%.1fx", zoom)
        }
    }
}

// MARK: - Compact Zoom Indicator

/// 컴팩트 줌 인디케이터 (프리뷰 위에 표시)
struct CompactZoomIndicator: View {
    
    let zoom: CGFloat
    
    /// 1x가 아닐 때만 표시
    var isVisible: Bool {
        abs(zoom - 1.0) > 0.05
    }
    
    var body: some View {
        if isVisible {
            Text(String(format: "%.1fx", zoom))
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.5))
                )
        }
    }
}

// MARK: - Pinch Zoom Handler

/// 핀치 줌 제스처를 처리하는 뷰 모디파이어
struct PinchZoomModifier: ViewModifier {
    
    @Binding var scale: CGFloat
    let range: ClosedRange<CGFloat>
    var onBegan: (() -> Void)?
    var onChanged: ((CGFloat) -> Void)?
    var onEnded: (() -> Void)?
    
    @State private var lastScale: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        if lastScale == 1.0 {
                            onBegan?()
                        }
                        
                        let delta = value / lastScale
                        lastScale = value
                        
                        let newScale = scale * delta
                        scale = min(max(newScale, range.lowerBound), range.upperBound)
                        
                        onChanged?(scale)
                    }
                    .onEnded { _ in
                        lastScale = 1.0
                        onEnded?()
                    }
            )
    }
}

extension View {
    /// 핀치 줌 제스처 추가
    func pinchToZoom(
        scale: Binding<CGFloat>,
        range: ClosedRange<CGFloat>,
        onBegan: (() -> Void)? = nil,
        onChanged: ((CGFloat) -> Void)? = nil,
        onEnded: (() -> Void)? = nil
    ) -> some View {
        modifier(PinchZoomModifier(
            scale: scale,
            range: range,
            onBegan: onBegan,
            onChanged: onChanged,
            onEnded: onEnded
        ))
    }
}

// MARK: - Preview

#Preview("줌 컨트롤") {
    ZStack {
        Color.black
        
        VStack {
            Spacer()
            
            ZoomControlView(
                currentZoom: .constant(1.0),
                zoomRange: 0.5...10.0,
                presets: [0.5, 1.0, 2.0, 3.0]
            )
            
            Spacer().frame(height: 100)
        }
    }
    .ignoresSafeArea()
}

#Preview("줌 프리셋 버튼") {
    HStack(spacing: 20) {
        ZoomPresetButton(zoom: 0.5, isSelected: false, action: {})
        ZoomPresetButton(zoom: 1.0, isSelected: true, action: {})
        ZoomPresetButton(zoom: 2.0, isSelected: false, action: {})
    }
    .padding()
    .background(Color.black)
}
