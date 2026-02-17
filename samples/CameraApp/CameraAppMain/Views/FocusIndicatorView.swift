import SwiftUI

// MARK: - 포커스 인디케이터 뷰
// 탭 투 포커스 시 표시되는 포커스 프레임 애니메이션입니다.
// HIG: 포커스 위치를 명확히 표시하고, 완료 시 자연스럽게 사라집니다.

struct FocusIndicatorView: View {
    
    // MARK: - Properties
    
    /// 포커스 위치 (화면 좌표)
    let position: CGPoint
    
    /// 노출 조정 활성화 여부
    var showExposure: Bool = false
    
    /// 노출 보정값 (-2.0 ~ 2.0)
    var exposureBias: Float = 0
    
    /// 노출 보정 변경 핸들러
    var onExposureChange: ((Float) -> Void)?
    
    // MARK: - State
    
    /// 애니메이션 스케일
    @State private var scale: CGFloat = 1.5
    
    /// 불투명도
    @State private var opacity: Double = 1.0
    
    /// 포커싱 완료 여부
    @State private var isFocused = false
    
    /// 노출 슬라이더 표시
    @State private var showExposureSlider = false
    
    // MARK: - Constants
    
    private let frameSize: CGFloat = 80
    private let cornerLength: CGFloat = 20
    private let lineWidth: CGFloat = 2
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // 포커스 프레임
            focusFrame
            
            // 노출 슬라이더
            if showExposure && showExposureSlider {
                exposureSlider
                    .offset(x: frameSize / 2 + 40)
            }
        }
        .position(adjustedPosition)
        .onAppear {
            startAnimation()
        }
    }
    
    // MARK: - Focus Frame
    
    private var focusFrame: some View {
        ZStack {
            // 모서리 코너 프레임
            ForEach(0..<4, id: \.self) { index in
                FocusCorner()
                    .stroke(Color.yellow, lineWidth: lineWidth)
                    .frame(width: cornerLength, height: cornerLength)
                    .rotationEffect(.degrees(Double(index) * 90))
                    .offset(
                        x: cornerOffset(for: index).x,
                        y: cornerOffset(for: index).y
                    )
            }
            
            // 중앙 십자선 (포커싱 중)
            if !isFocused {
                crosshair
            }
        }
        .frame(width: frameSize, height: frameSize)
        .scaleEffect(scale)
        .opacity(opacity)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                showExposureSlider.toggle()
            }
        }
    }
    
    // MARK: - Crosshair
    
    private var crosshair: some View {
        ZStack {
            // 가로선
            Rectangle()
                .fill(Color.yellow.opacity(0.5))
                .frame(width: 20, height: 1)
            
            // 세로선
            Rectangle()
                .fill(Color.yellow.opacity(0.5))
                .frame(width: 1, height: 20)
        }
    }
    
    // MARK: - Exposure Slider
    
    private var exposureSlider: some View {
        VStack(spacing: 8) {
            // 태양 아이콘 (밝게)
            Image(systemName: "sun.max.fill")
                .font(.system(size: 12))
                .foregroundColor(.yellow)
            
            // 세로 슬라이더
            VerticalSlider(
                value: Binding(
                    get: { exposureBias },
                    set: { onExposureChange?($0) }
                ),
                range: -2.0...2.0
            )
            .frame(width: 30, height: 150)
            
            // 태양 아이콘 (어둡게)
            Image(systemName: "sun.min")
                .font(.system(size: 12))
                .foregroundColor(.yellow.opacity(0.5))
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.5))
        )
    }
    
    // MARK: - Helpers
    
    /// 화면 경계 고려한 조정된 위치
    private var adjustedPosition: CGPoint {
        position
    }
    
    /// 코너 오프셋 계산
    private func cornerOffset(for index: Int) -> CGPoint {
        let offset = (frameSize - cornerLength) / 2
        
        switch index {
        case 0: return CGPoint(x: -offset, y: -offset)  // 좌상단
        case 1: return CGPoint(x: offset, y: -offset)   // 우상단
        case 2: return CGPoint(x: offset, y: offset)    // 우하단
        case 3: return CGPoint(x: -offset, y: offset)   // 좌하단
        default: return .zero
        }
    }
    
    /// 애니메이션 시작
    private func startAnimation() {
        // 축소 애니메이션
        withAnimation(.easeOut(duration: 0.3)) {
            scale = 1.0
        }
        
        // 포커싱 완료 (1초 후)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.2)) {
                isFocused = true
            }
        }
        
        // 페이드아웃 (2초 후)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                opacity = 0
            }
        }
    }
}

// MARK: - Focus Corner Shape

/// 포커스 프레임 코너 모양
struct FocusCorner: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // ㄴ 모양 그리기
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        
        return path
    }
}

// MARK: - Vertical Slider

/// 세로 방향 슬라이더
struct VerticalSlider: View {
    @Binding var value: Float
    let range: ClosedRange<Float>
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 트랙
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 4)
                
                // 중앙 표시
                Circle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 8, height: 8)
                
                // 현재 값 표시
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 20, height: 20)
                    .shadow(color: .black.opacity(0.3), radius: 2)
                    .offset(y: thumbOffset(in: geometry.size.height))
            }
            .frame(maxWidth: .infinity)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        updateValue(from: gesture.location.y, height: geometry.size.height)
                    }
            )
        }
    }
    
    /// 썸 위치 계산
    private func thumbOffset(in height: CGFloat) -> CGFloat {
        let normalizedValue = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        let offset = height / 2 - CGFloat(normalizedValue) * height
        return offset
    }
    
    /// 드래그로 값 업데이트
    private func updateValue(from y: CGFloat, height: CGFloat) {
        let normalizedValue = 1 - (y / height)
        let clampedValue = min(1, max(0, Float(normalizedValue)))
        value = range.lowerBound + clampedValue * (range.upperBound - range.lowerBound)
    }
}

// MARK: - 포커스/노출 잠금 인디케이터

struct AEAFLockIndicator: View {
    
    enum LockType {
        case focus       // AF Lock
        case exposure    // AE Lock
        case both        // AE/AF Lock
    }
    
    let lockType: LockType
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "lock.fill")
                .font(.system(size: 10))
            
            Text(lockText)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundColor(.yellow)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.6))
        )
    }
    
    private var lockText: String {
        switch lockType {
        case .focus: "AF 잠금"
        case .exposure: "AE 잠금"
        case .both: "AE/AF 잠금"
        }
    }
}

// MARK: - Preview

#Preview("포커스 인디케이터") {
    ZStack {
        Color.black
        
        FocusIndicatorView(
            position: CGPoint(x: 200, y: 400),
            showExposure: true,
            exposureBias: 0.5
        )
    }
    .ignoresSafeArea()
}

#Preview("AE/AF 잠금") {
    VStack(spacing: 20) {
        AEAFLockIndicator(lockType: .focus)
        AEAFLockIndicator(lockType: .exposure)
        AEAFLockIndicator(lockType: .both)
    }
    .padding()
    .background(Color.gray)
}
