import SwiftUI

// MARK: - 카메라 컨트롤 뷰
// 상단/하단 컨트롤 바와 모드 선택기를 통합한 뷰입니다.
// HIG: 자주 사용하는 컨트롤은 쉽게 접근 가능한 위치에, 고급 설정은 메뉴에 배치합니다.

// MARK: - 상단 컨트롤 바

struct TopControlBar: View {
    
    // MARK: - Properties
    
    /// 플래시 모드
    @Binding var flashMode: FlashMode
    
    /// 타이머 설정
    @Binding var timerSetting: TimerSetting
    
    /// HDR 모드
    @Binding var hdrMode: HDRMode
    
    /// 카메라 위치
    let cameraPosition: CameraPosition
    
    /// 플래시 지원 여부
    let hasFlash: Bool
    
    /// 설정 버튼 액션
    var onSettingsPressed: (() -> Void)?
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 16) {
            // 플래시 버튼
            flashButton
            
            Spacer()
            
            // HDR 버튼
            hdrButton
            
            // 타이머 버튼
            timerButton
            
            Spacer()
            
            // 설정 버튼
            settingsButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.6), Color.black.opacity(0)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - Flash Button
    
    private var flashButton: some View {
        Button {
            cycleFlashMode()
        } label: {
            Image(systemName: flashMode.symbol)
                .font(.system(size: 20))
                .foregroundColor(flashButtonColor)
                .frame(width: 44, height: 44)
        }
        .opacity(hasFlash && cameraPosition == .back ? 1 : 0.3)
        .disabled(!hasFlash || cameraPosition == .front)
        .accessibilityLabel("플래시")
        .accessibilityValue(flashMode.rawValue)
    }
    
    private var flashButtonColor: Color {
        switch flashMode {
        case .on: .yellow
        case .auto: .yellow.opacity(0.8)
        case .off: .white
        }
    }
    
    private func cycleFlashMode() {
        withAnimation(.easeInOut(duration: 0.2)) {
            flashMode = flashMode.next
        }
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    // MARK: - HDR Button
    
    private var hdrButton: some View {
        Button {
            cycleHDRMode()
        } label: {
            ZStack {
                Text("HDR")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(hdrButtonColor)
                
                if hdrMode == .off {
                    // 취소선
                    Rectangle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 30, height: 1)
                        .rotationEffect(.degrees(-15))
                }
            }
            .frame(width: 44, height: 44)
        }
        .accessibilityLabel("HDR")
        .accessibilityValue(hdrMode.rawValue)
    }
    
    private var hdrButtonColor: Color {
        switch hdrMode {
        case .on: .yellow
        case .auto: .white.opacity(0.8)
        case .off: .white.opacity(0.5)
        }
    }
    
    private func cycleHDRMode() {
        withAnimation(.easeInOut(duration: 0.2)) {
            switch hdrMode {
            case .auto: hdrMode = .on
            case .on: hdrMode = .off
            case .off: hdrMode = .auto
            }
        }
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    // MARK: - Timer Button
    
    private var timerButton: some View {
        Button {
            cycleTimerSetting()
        } label: {
            ZStack {
                Image(systemName: timerSetting.symbol)
                    .font(.system(size: 20))
                
                if timerSetting != .off {
                    Text("\(timerSetting.rawValue)")
                        .font(.system(size: 10, weight: .bold))
                        .offset(x: 10, y: 8)
                }
            }
            .foregroundColor(timerSetting == .off ? .white : .yellow)
            .frame(width: 44, height: 44)
        }
        .accessibilityLabel("타이머")
        .accessibilityValue(timerSetting.displayText)
    }
    
    private func cycleTimerSetting() {
        withAnimation(.easeInOut(duration: 0.2)) {
            timerSetting = timerSetting.next
        }
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    // MARK: - Settings Button
    
    private var settingsButton: some View {
        Button {
            onSettingsPressed?()
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
        }
        .accessibilityLabel("설정")
    }
}

// MARK: - 캡처 모드 선택기

struct CaptureModeSelector: View {
    
    @Binding var selectedMode: CaptureMode
    
    var body: some View {
        HStack(spacing: 24) {
            ForEach(CaptureMode.allCases, id: \.self) { mode in
                Button {
                    selectMode(mode)
                } label: {
                    Text(mode.rawValue)
                        .font(.system(size: 14, weight: selectedMode == mode ? .bold : .regular))
                        .foregroundColor(selectedMode == mode ? .yellow : .white.opacity(0.7))
                }
            }
        }
        .padding(.vertical, 12)
    }
    
    private func selectMode(_ mode: CaptureMode) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedMode = mode
        }
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// MARK: - 하단 컨트롤 바

struct BottomControlBar: View {
    
    // MARK: - Properties
    
    /// 캡처 모드
    let captureMode: CaptureMode
    
    /// 녹화 중 여부
    let isRecording: Bool
    
    /// 마지막 촬영 미디어 (썸네일용)
    let lastMedia: CapturedMedia?
    
    /// 촬영 버튼 액션
    var onCapturePressed: (() -> Void)?
    
    /// 촬영 버튼 길게 누름 (연속 촬영)
    var onCaptureLongPressed: (() -> Void)?
    
    /// 촬영 버튼 뗌 (연속 촬영 종료)
    var onCaptureReleased: (() -> Void)?
    
    /// 갤러리 버튼 액션
    var onGalleryPressed: (() -> Void)?
    
    /// 카메라 전환 액션
    var onSwitchCamera: (() -> Void)?
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .center) {
            // 갤러리 썸네일
            galleryButton
            
            Spacer()
            
            // 촬영 버튼
            captureButton
            
            Spacer()
            
            // 카메라 전환 버튼
            switchCameraButton
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 20)
        .background(Color.black)
    }
    
    // MARK: - Gallery Button
    
    private var galleryButton: some View {
        Button {
            onGalleryPressed?()
        } label: {
            Group {
                if let media = lastMedia {
                    Image(uiImage: media.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundColor(.white.opacity(0.5))
                        }
                }
            }
            .frame(width: 60, height: 60)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
            )
        }
        .accessibilityLabel("갤러리")
    }
    
    // MARK: - Capture Button
    
    private var captureButton: some View {
        Group {
            switch captureMode {
            case .photo:
                PhotoCaptureButton(
                    onTap: { onCapturePressed?() },
                    onLongPress: { onCaptureLongPressed?() },
                    onRelease: { onCaptureReleased?() }
                )
                
            case .video:
                VideoCaptureButton(
                    isRecording: isRecording,
                    onTap: { onCapturePressed?() }
                )
                
            case .qrCode:
                // QR 모드에서는 셔터 버튼 대신 안내 표시
                QRCaptureIndicator()
            }
        }
    }
    
    // MARK: - Switch Camera Button
    
    private var switchCameraButton: some View {
        Button {
            onSwitchCamera?()
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
        }
        .opacity(captureMode == .qrCode ? 0.5 : 1)
        .accessibilityLabel("카메라 전환")
    }
}

// MARK: - 사진 촬영 버튼

struct PhotoCaptureButton: View {
    
    var onTap: (() -> Void)?
    var onLongPress: (() -> Void)?
    var onRelease: (() -> Void)?
    
    @State private var isPressed = false
    @State private var isLongPressing = false
    
    private let outerSize: CGFloat = 80
    private let innerSize: CGFloat = 64
    
    var body: some View {
        ZStack {
            // 외부 링
            Circle()
                .stroke(Color.white, lineWidth: 4)
                .frame(width: outerSize, height: outerSize)
            
            // 내부 원
            Circle()
                .fill(Color.white)
                .frame(width: innerSize, height: innerSize)
                .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                        
                        // 길게 누르기 감지 (0.5초)
                        Task {
                            try? await Task.sleep(nanoseconds: 500_000_000)
                            if isPressed {
                                isLongPressing = true
                                onLongPress?()
                            }
                        }
                    }
                }
                .onEnded { _ in
                    if isLongPressing {
                        onRelease?()
                    } else {
                        onTap?()
                    }
                    
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                    isLongPressing = false
                }
        )
        .accessibilityLabel("촬영")
        .accessibilityHint("탭하여 촬영, 길게 눌러 연속 촬영")
    }
}

// MARK: - 비디오 녹화 버튼

struct VideoCaptureButton: View {
    
    let isRecording: Bool
    var onTap: (() -> Void)?
    
    private let outerSize: CGFloat = 80
    
    var body: some View {
        Button {
            onTap?()
        } label: {
            ZStack {
                // 외부 링
                Circle()
                    .stroke(Color.white, lineWidth: 4)
                    .frame(width: outerSize, height: outerSize)
                
                // 내부 (녹화 중이면 사각형, 아니면 원)
                if isRecording {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.red)
                        .frame(width: 32, height: 32)
                } else {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 64, height: 64)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isRecording)
        .accessibilityLabel(isRecording ? "녹화 중지" : "녹화 시작")
    }
}

// MARK: - QR 스캔 인디케이터

struct QRCaptureIndicator: View {
    
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // 스캔 프레임
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.yellow, lineWidth: 3)
                .frame(width: 70, height: 70)
            
            // 스캔 라인 애니메이션
            Rectangle()
                .fill(Color.yellow.opacity(0.5))
                .frame(width: 60, height: 2)
                .offset(y: isAnimating ? 25 : -25)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }
}

// MARK: - 녹화 시간 표시

struct RecordingTimeIndicator: View {
    
    let duration: String
    let isRecording: Bool
    
    @State private var isBlinking = false
    
    var body: some View {
        HStack(spacing: 8) {
            // 녹화 표시등
            Circle()
                .fill(Color.red)
                .frame(width: 10, height: 10)
                .opacity(isBlinking ? 0.3 : 1.0)
            
            // 시간
            Text(duration)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.6))
        )
        .onAppear {
            guard isRecording else { return }
            withAnimation(
                .easeInOut(duration: 0.5)
                .repeatForever(autoreverses: true)
            ) {
                isBlinking = true
            }
        }
        .onChange(of: isRecording) { _, recording in
            if !recording {
                isBlinking = false
            }
        }
    }
}

// MARK: - Preview

#Preview("상단 컨트롤 바") {
    VStack {
        TopControlBar(
            flashMode: .constant(.auto),
            timerSetting: .constant(.off),
            hdrMode: .constant(.auto),
            cameraPosition: .back,
            hasFlash: true
        )
        
        Spacer()
    }
    .background(Color.gray)
}

#Preview("모드 선택기") {
    ZStack {
        Color.black
        CaptureModeSelector(selectedMode: .constant(.photo))
    }
}

#Preview("하단 컨트롤 바") {
    VStack {
        Spacer()
        
        BottomControlBar(
            captureMode: .photo,
            isRecording: false,
            lastMedia: nil
        )
    }
    .background(Color.gray)
}

#Preview("녹화 시간") {
    RecordingTimeIndicator(duration: "01:23", isRecording: true)
        .padding()
        .background(Color.gray)
}
