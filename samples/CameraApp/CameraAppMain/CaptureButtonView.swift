import SwiftUI

// MARK: - 셔터 버튼 뷰
// HIG: 촬영 버튼은 손쉽게 접근할 수 있는 위치에 크게 배치합니다.
// 탭 시 시각적 피드백으로 사용자에게 촬영이 시작됨을 알립니다.

struct CaptureButtonView: View {
    
    // MARK: - Properties
    
    /// 촬영 액션
    let action: () -> Void
    
    // MARK: - State
    
    /// 버튼 눌림 상태
    @State private var isPressed = false
    
    /// 촬영 애니메이션 상태
    @State private var captureAnimation = false
    
    // MARK: - Constants
    
    /// 버튼 외부 링 크기
    private let outerSize: CGFloat = 80
    
    /// 버튼 내부 원 크기
    private let innerSize: CGFloat = 64
    
    // MARK: - Body
    
    var body: some View {
        Button {
            performCapture()
        } label: {
            ZStack {
                // 외부 링
                Circle()
                    .stroke(Color.white, lineWidth: 4)
                    .frame(width: outerSize, height: outerSize)
                
                // 내부 원 (촬영 버튼)
                Circle()
                    .fill(Color.white)
                    .frame(width: innerSize, height: innerSize)
                    .scaleEffect(isPressed ? 0.9 : 1.0)
                    .scaleEffect(captureAnimation ? 0.85 : 1.0)
            }
        }
        .buttonStyle(CaptureButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
        .accessibilityLabel("촬영")
        .accessibilityHint("탭하여 사진을 촬영합니다")
    }
    
    // MARK: - Private Methods
    
    /// 촬영 수행 및 애니메이션
    private func performCapture() {
        // 촬영 애니메이션
        withAnimation(.easeOut(duration: 0.1)) {
            captureAnimation = true
        }
        
        // 촬영 액션 실행
        action()
        
        // 햅틱 피드백
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // 애니메이션 복구
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeIn(duration: 0.1)) {
                captureAnimation = false
            }
        }
    }
}

// MARK: - 커스텀 버튼 스타일

/// 셔터 버튼 전용 스타일 (기본 효과 제거)
struct CaptureButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black
        
        VStack(spacing: 40) {
            CaptureButtonView {
                print("📸 촬영!")
            }
            
            Text("탭하여 촬영")
                .foregroundColor(.white)
                .font(.caption)
        }
    }
}
