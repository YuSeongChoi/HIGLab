// ExtensionSettingsView.swift
// SmartCrop - HIG Lab 샘플 프로젝트
// iOS 26 ExtensibleImage API 활용

import SwiftUI

/// 이미지 확장(아웃페인팅) 설정을 조정하는 뷰
/// 각 방향별 확장 비율을 개별적으로 또는 일괄적으로 설정할 수 있습니다
struct ExtensionSettingsView: View {
    /// 확장 설정 (바인딩)
    @Binding var settings: ExtensionSettings
    
    /// 균등 확장 모드
    @State private var useUniformExtension = true
    
    /// 균등 확장 값
    @State private var uniformValue: CGFloat = 0.2
    
    /// 미리보기 이미지
    var previewImage: UIImage?
    
    var body: some View {
        VStack(spacing: 24) {
            // 미리보기
            if let image = previewImage {
                extensionPreview(for: image)
            }
            
            // 모드 선택
            modeToggle
            
            // 확장 설정 슬라이더
            if useUniformExtension {
                uniformSlider
            } else {
                individualSliders
            }
            
            // 프리셋 버튼
            presetButtons
        }
        .padding()
        .onChange(of: uniformValue) { _, newValue in
            if useUniformExtension {
                settings.setUniform(newValue)
            }
        }
    }
    
    // MARK: - 미리보기
    
    private func extensionPreview(for image: UIImage) -> some View {
        GeometryReader { geometry in
            let maxSize = min(geometry.size.width, 200.0)
            
            ZStack {
                // 확장될 영역 (점선)
                RoundedRectangle(cornerRadius: 8)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    .foregroundStyle(.blue.opacity(0.5))
                    .frame(
                        width: maxSize * (1 + settings.leftPadding + settings.rightPadding),
                        height: maxSize * (1 + settings.topPadding + settings.bottomPadding)
                    )
                
                // 원본 이미지 영역
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: maxSize, height: maxSize)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.primary, lineWidth: 2)
                    }
                    .offset(
                        x: (settings.leftPadding - settings.rightPadding) * maxSize / 2,
                        y: (settings.topPadding - settings.bottomPadding) * maxSize / 2
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 250)
    }
    
    // MARK: - 모드 토글
    
    private var modeToggle: some View {
        Picker("확장 모드", selection: $useUniformExtension) {
            Text("균등 확장").tag(true)
            Text("개별 설정").tag(false)
        }
        .pickerStyle(.segmented)
    }
    
    // MARK: - 균등 슬라이더
    
    private var uniformSlider: some View {
        VStack(spacing: 12) {
            HStack {
                Text("확장 비율")
                Spacer()
                Text("\(Int(uniformValue * 100))%")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            
            Slider(value: $uniformValue, in: 0.05...1.0, step: 0.05) {
                Text("확장 비율")
            } minimumValueLabel: {
                Text("5%")
                    .font(.caption2)
            } maximumValueLabel: {
                Text("100%")
                    .font(.caption2)
            }
            .tint(.blue)
        }
    }
    
    // MARK: - 개별 슬라이더
    
    private var individualSliders: some View {
        VStack(spacing: 16) {
            directionSlider(
                title: "상단",
                icon: "arrow.up",
                value: $settings.topPadding
            )
            
            directionSlider(
                title: "하단",
                icon: "arrow.down",
                value: $settings.bottomPadding
            )
            
            directionSlider(
                title: "좌측",
                icon: "arrow.left",
                value: $settings.leftPadding
            )
            
            directionSlider(
                title: "우측",
                icon: "arrow.right",
                value: $settings.rightPadding
            )
        }
    }
    
    /// 방향별 슬라이더
    private func directionSlider(
        title: String,
        icon: String,
        value: Binding<CGFloat>
    ) -> some View {
        VStack(spacing: 8) {
            HStack {
                Label(title, systemImage: icon)
                    .frame(width: 80, alignment: .leading)
                
                Slider(value: value, in: 0...1.0, step: 0.05)
                    .tint(.blue)
                
                Text("\(Int(value.wrappedValue * 100))%")
                    .monospacedDigit()
                    .frame(width: 45, alignment: .trailing)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - 프리셋 버튼
    
    private var presetButtons: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("프리셋")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                presetButton(title: "정사각형", icon: "square") {
                    withAnimation {
                        settings.setUniform(0.2)
                        uniformValue = 0.2
                        useUniformExtension = true
                    }
                }
                
                presetButton(title: "세로 확장", icon: "rectangle.portrait") {
                    withAnimation {
                        settings.setVertical(0.3)
                        useUniformExtension = false
                    }
                }
                
                presetButton(title: "가로 확장", icon: "rectangle") {
                    withAnimation {
                        settings.setHorizontal(0.3)
                        useUniformExtension = false
                    }
                }
                
                presetButton(title: "와이드", icon: "rectangle.ratio.16.to.9") {
                    withAnimation {
                        settings = ExtensionSettings(
                            topPadding: 0.1,
                            bottomPadding: 0.1,
                            leftPadding: 0.5,
                            rightPadding: 0.5
                        )
                        useUniformExtension = false
                    }
                }
            }
        }
    }
    
    /// 프리셋 버튼
    private func presetButton(
        title: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.tertiarySystemBackground))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 확장 방향 표시 뷰

/// 확장 방향과 크기를 시각적으로 표시하는 뷰
struct ExtensionDirectionIndicator: View {
    let settings: ExtensionSettings
    
    var body: some View {
        VStack(spacing: 8) {
            // 상단
            directionBar(value: settings.topPadding, direction: .top)
            
            HStack(spacing: 8) {
                // 좌측
                directionBar(value: settings.leftPadding, direction: .left)
                
                // 중앙 (원본 이미지 영역)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray4))
                    .frame(width: 60, height: 60)
                    .overlay {
                        Text("원본")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                
                // 우측
                directionBar(value: settings.rightPadding, direction: .right)
            }
            
            // 하단
            directionBar(value: settings.bottomPadding, direction: .bottom)
        }
        .padding()
    }
    
    private func directionBar(value: CGFloat, direction: Direction) -> some View {
        let isVertical = direction == .top || direction == .bottom
        let size = max(value * 60, 10)
        
        return Group {
            if isVertical {
                Rectangle()
                    .fill(Color.blue.opacity(0.3 + value * 0.5))
                    .frame(width: 60, height: size)
            } else {
                Rectangle()
                    .fill(Color.blue.opacity(0.3 + value * 0.5))
                    .frame(width: size, height: 60)
            }
        }
        .overlay {
            if value > 0.1 {
                Text("\(Int(value * 100))%")
                    .font(.system(size: 8))
                    .foregroundStyle(.white)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 2))
    }
    
    private enum Direction {
        case top, bottom, left, right
    }
}

// MARK: - 미리보기

#Preview("설정 뷰") {
    @Previewable @State var settings = ExtensionSettings()
    
    ExtensionSettingsView(
        settings: $settings,
        previewImage: UIImage(systemName: "photo")
    )
}

#Preview("방향 표시") {
    ExtensionDirectionIndicator(
        settings: ExtensionSettings(
            topPadding: 0.2,
            bottomPadding: 0.3,
            leftPadding: 0.1,
            rightPadding: 0.4
        )
    )
}
