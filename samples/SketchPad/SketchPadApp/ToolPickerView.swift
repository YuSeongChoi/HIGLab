import SwiftUI

// MARK: - ToolPickerView
// 도구 및 색상 선택을 위한 시트 뷰

struct ToolPickerView: View {
    // MARK: - 환경
    
    @Environment(ToolPalette.self) private var palette
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - 본문
    
    var body: some View {
        NavigationStack {
            List {
                // 도구 선택 섹션
                toolSection
                
                // 색상 선택 섹션
                colorSection
                
                // 선 두께 섹션
                lineWidthSection
                
                // 불투명도 섹션
                opacitySection
                
                // 리셋 버튼
                resetSection
            }
            .navigationTitle("도구 설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - 도구 선택 섹션
    
    private var toolSection: some View {
        Section {
            ForEach(ToolType.allCases) { tool in
                Button {
                    palette.selectTool(tool)
                } label: {
                    HStack {
                        Image(systemName: tool.icon)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading) {
                            Text(tool.rawValue)
                                .foregroundStyle(.primary)
                            Text(tool.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if palette.selectedTool == tool {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        } header: {
            Text("도구")
        }
    }
    
    // MARK: - 색상 선택 섹션
    
    private var colorSection: some View {
        Section {
            // 프리셋 색상 그리드
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 6),
                spacing: 12
            ) {
                ForEach(ToolPalette.presetColors, id: \.self) { color in
                    colorSwatch(color)
                }
            }
            .padding(.vertical, 8)
            
            // 커스텀 색상 선택
            HStack {
                Text("사용자 지정")
                Spacer()
                ColorPicker("", selection: Bindable(palette).selectedColor)
                    .labelsHidden()
            }
        } header: {
            Text("색상")
        }
    }
    
    /// 색상 견본 버튼
    private func colorSwatch(_ color: Color) -> some View {
        Button {
            palette.selectColor(color)
        } label: {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 36, height: 36)
                
                // 흰색인 경우 테두리 추가
                if color == .white {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        .frame(width: 36, height: 36)
                }
                
                // 선택 표시
                if colorsMatch(palette.selectedColor, color) {
                    Circle()
                        .stroke(Color.blue, lineWidth: 3)
                        .frame(width: 42, height: 42)
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    /// 색상 비교 (근사치)
    private func colorsMatch(_ c1: Color, _ c2: Color) -> Bool {
        // SwiftUI Color 비교는 정확하지 않을 수 있으므로
        // UIColor로 변환하여 비교
        let uiColor1 = UIColor(c1)
        let uiColor2 = UIColor(c2)
        
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        uiColor1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        uiColor2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        let threshold: CGFloat = 0.01
        return abs(r1 - r2) < threshold &&
               abs(g1 - g2) < threshold &&
               abs(b1 - b2) < threshold
    }
    
    // MARK: - 선 두께 섹션
    
    private var lineWidthSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                // 프리셋 두께
                HStack(spacing: 16) {
                    ForEach(ToolPalette.presetWidths, id: \.self) { width in
                        Button {
                            palette.setLineWidth(width)
                        } label: {
                            Circle()
                                .fill(palette.selectedColor)
                                .frame(width: width + 10, height: width + 10)
                                .overlay {
                                    if palette.lineWidth == width {
                                        Circle()
                                            .stroke(Color.blue, lineWidth: 2)
                                            .frame(width: width + 16, height: width + 16)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(height: 40)
                
                // 슬라이더
                HStack {
                    Text("두께: \(Int(palette.lineWidth))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Slider(
                        value: Bindable(palette).lineWidth,
                        in: 1...50,
                        step: 1
                    )
                }
            }
            .padding(.vertical, 8)
            
            // 지우개 크기 (지우개 선택 시)
            if palette.selectedTool == .eraser {
                HStack {
                    Text("지우개 크기: \(Int(palette.eraserWidth))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Slider(
                        value: Bindable(palette).eraserWidth,
                        in: 5...100,
                        step: 5
                    )
                }
            }
        } header: {
            Text("크기")
        }
    }
    
    // MARK: - 불투명도 섹션
    
    private var opacitySection: some View {
        Section {
            HStack {
                Text("불투명도: \(Int(palette.opacity * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Slider(
                    value: Bindable(palette).opacity,
                    in: 0.1...1.0,
                    step: 0.1
                )
            }
            
            // 불투명도 미리보기
            RoundedRectangle(cornerRadius: 8)
                .fill(palette.selectedColor.opacity(palette.opacity))
                .frame(height: 30)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                }
        } header: {
            Text("불투명도")
        }
    }
    
    // MARK: - 리셋 섹션
    
    private var resetSection: some View {
        Section {
            Button(role: .destructive) {
                palette.reset()
            } label: {
                HStack {
                    Spacer()
                    Text("기본값으로 리셋")
                    Spacer()
                }
            }
        }
    }
}

// MARK: - 미리보기

#Preview {
    ToolPickerView()
        .environment(ToolPalette.preview)
}
