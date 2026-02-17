import SwiftUI

// MARK: - 타이머 오버레이 뷰
// 타이머 촬영 시 카운트다운을 전체 화면에 표시합니다.
// HIG: 카운트다운은 명확하고 큰 숫자로 표시하여 사용자가 쉽게 인지할 수 있도록 합니다.

struct TimerOverlayView: View {
    
    // MARK: - Properties
    
    /// 남은 초
    let countdown: Int
    
    /// 취소 핸들러
    var onCancel: (() -> Void)?
    
    // MARK: - State
    
    /// 숫자 스케일 애니메이션
    @State private var scale: CGFloat = 0.5
    
    /// 숫자 불투명도
    @State private var opacity: Double = 0
    
    /// 펄스 애니메이션
    @State private var pulseScale: CGFloat = 1.0
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // 반투명 배경
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            // 펄스 링
            pulseRing
            
            // 카운트다운 숫자
            countdownNumber
            
            // 취소 버튼
            VStack {
                Spacer()
                cancelButton
                    .padding(.bottom, 100)
            }
        }
        .onAppear {
            startAnimations()
        }
        .onChange(of: countdown) { _, newValue in
            resetAnimation()
        }
    }
    
    // MARK: - Countdown Number
    
    private var countdownNumber: some View {
        Text("\(countdown)")
            .font(.system(size: 180, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.5), radius: 10)
            .scaleEffect(scale)
            .opacity(opacity)
    }
    
    // MARK: - Pulse Ring
    
    private var pulseRing: some View {
        Circle()
            .stroke(Color.white.opacity(0.3), lineWidth: 4)
            .frame(width: 200, height: 200)
            .scaleEffect(pulseScale)
            .opacity(2 - Double(pulseScale))
    }
    
    // MARK: - Cancel Button
    
    private var cancelButton: some View {
        Button {
            onCancel?()
        } label: {
            Text("취소")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                )
        }
    }
    
    // MARK: - Animations
    
    private func startAnimations() {
        // 숫자 등장
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            scale = 1.0
            opacity = 1.0
        }
        
        // 펄스 효과
        withAnimation(
            .easeOut(duration: 1.0)
            .repeatForever(autoreverses: false)
        ) {
            pulseScale = 2.0
        }
    }
    
    private func resetAnimation() {
        scale = 0.5
        opacity = 0
        pulseScale = 1.0
        
        startAnimations()
        
        // 햅틱 피드백
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
}

// MARK: - 촬영 완료 플래시 효과

struct CaptureFlashEffect: View {
    
    /// 플래시 활성화
    @Binding var isActive: Bool
    
    var body: some View {
        Color.white
            .opacity(isActive ? 1 : 0)
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .onChange(of: isActive) { _, active in
                if active {
                    // 짧게 깜빡인 후 비활성화
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeOut(duration: 0.15)) {
                            isActive = false
                        }
                    }
                }
            }
    }
}

// MARK: - 연속 촬영 (Burst) 인디케이터

struct BurstModeIndicator: View {
    
    /// 현재 촬영 수
    let count: Int
    
    /// 최대 촬영 수
    let maxCount: Int
    
    var body: some View {
        VStack(spacing: 8) {
            // 연속 촬영 아이콘
            Image(systemName: "square.stack.3d.down.right.fill")
                .font(.system(size: 40))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 5)
            
            // 촬영 수 카운터
            Text("\(count)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 5)
            
            // 진행 바
            ProgressView(value: Double(count), total: Double(maxCount))
                .progressViewStyle(.linear)
                .tint(.yellow)
                .frame(width: 100)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.5))
        )
    }
}

// MARK: - 촬영 성공 인디케이터

struct CaptureSuccessIndicator: View {
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 60))
            .foregroundColor(.green)
            .shadow(color: .black.opacity(0.3), radius: 5)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.0
                    opacity = 1.0
                }
                
                // 1초 후 페이드아웃
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        opacity = 0
                    }
                }
            }
    }
}

// MARK: - 저장 중 인디케이터

struct SavingIndicator: View {
    
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack(spacing: 12) {
            // 회전하는 아이콘
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .rotationEffect(.degrees(rotation))
            
            Text("저장 중...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.6))
        )
        .onAppear {
            withAnimation(
                .linear(duration: 1.0)
                .repeatForever(autoreverses: false)
            ) {
                rotation = 360
            }
        }
    }
}

// MARK: - 권한 요청 오버레이

struct PermissionRequestOverlay: View {
    
    enum PermissionType {
        case camera
        case microphone
        case photoLibrary
    }
    
    let permissionType: PermissionType
    var onOpenSettings: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 24) {
            // 아이콘
            Image(systemName: iconName)
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.7))
            
            // 제목
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            // 설명
            Text(description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // 설정 버튼
            Button {
                onOpenSettings?()
            } label: {
                Text("설정 열기")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.white)
                    )
            }
        }
    }
    
    private var iconName: String {
        switch permissionType {
        case .camera: "camera.fill"
        case .microphone: "mic.fill"
        case .photoLibrary: "photo.on.rectangle"
        }
    }
    
    private var title: String {
        switch permissionType {
        case .camera: "카메라 접근 권한 필요"
        case .microphone: "마이크 접근 권한 필요"
        case .photoLibrary: "사진 접근 권한 필요"
        }
    }
    
    private var description: String {
        switch permissionType {
        case .camera:
            "사진과 비디오를 촬영하려면 카메라 접근 권한이 필요합니다."
        case .microphone:
            "비디오 녹화 시 소리를 녹음하려면 마이크 접근 권한이 필요합니다."
        case .photoLibrary:
            "촬영한 사진과 비디오를 저장하려면 사진 접근 권한이 필요합니다."
        }
    }
}

// MARK: - Preview

#Preview("타이머 오버레이") {
    TimerOverlayView(countdown: 3)
}

#Preview("연속 촬영") {
    ZStack {
        Color.gray
        BurstModeIndicator(count: 5, maxCount: 10)
    }
}

#Preview("촬영 성공") {
    ZStack {
        Color.gray
        CaptureSuccessIndicator()
    }
}

#Preview("저장 중") {
    ZStack {
        Color.gray
        SavingIndicator()
    }
}

#Preview("권한 요청") {
    ZStack {
        Color.black
        PermissionRequestOverlay(permissionType: .camera)
    }
    .ignoresSafeArea()
}
