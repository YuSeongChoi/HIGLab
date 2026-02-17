import SwiftUI
import ImagePlayground

// MARK: - ImageGeneratorView
// 이미지 생성 메인 화면
// 프롬프트 입력, 스타일 선택, Image Playground 실행

/// 이미지 생성 뷰
struct ImageGeneratorView: View {
    
    // MARK: - Environment
    
    @EnvironmentObject private var viewModel: ImageMakerViewModel
    
    // MARK: - State
    
    /// 키보드 포커스 상태
    @FocusState private var isPromptFocused: Bool
    
    /// 프리셋 시트 표시
    @State private var showPresets = false
    
    /// 스타일 팁 표시
    @State private var showStyleTip = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 헤더 영역
                    headerSection
                    
                    // 프롬프트 입력 영역
                    promptInputSection
                    
                    // 스타일 선택 영역
                    styleSelectionSection
                    
                    // 생성 버튼
                    generateButton
                    
                    // 최근 생성 이미지
                    if let lastImage = viewModel.lastGeneratedImage {
                        lastGeneratedSection(image: lastImage)
                    }
                    
                    // 추천 프리셋
                    presetsSection
                }
                .padding()
            }
            .navigationTitle("이미지 만들기")
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Button("완료") {
                        isPromptFocused = false
                    }
                }
            }
            .sheet(isPresented: $showPresets) {
                PresetPickerSheet()
            }
            .imagePlaygroundSheet(
                isPresented: $viewModel.showingImagePlayground,
                concepts: playgroundConcepts,
                style: viewModel.selectedStyle.playgroundStyle
            ) { url in
                // 생성된 이미지 처리
                viewModel.handleGeneratedImage(url)
            }
        }
    }
    
    // MARK: - Subviews
    
    /// 헤더 섹션
    private var headerSection: some View {
        VStack(spacing: 8) {
            // AI 아이콘
            ZStack {
                Circle()
                    .fill(AppTheme.primaryGradient)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 36))
                    .foregroundStyle(.white)
            }
            .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
            
            Text("상상을 그림으로")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("텍스트를 입력하면 AI가 이미지를 생성합니다")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical)
    }
    
    /// 프롬프트 입력 섹션
    private var promptInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 섹션 헤더
            HStack {
                Label("프롬프트", systemImage: "text.bubble")
                    .font(.headline)
                
                Spacer()
                
                // 글자 수 표시
                Text("\(viewModel.promptCharacterCount)/\(AppConstants.maxPromptLength)")
                    .font(.caption)
                    .foregroundStyle(
                        viewModel.promptCharacterCount > AppConstants.maxPromptLength
                        ? .red : .secondary
                    )
            }
            
            // 텍스트 입력
            TextField("어떤 이미지를 만들고 싶으세요?", text: $viewModel.currentPrompt, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(3...6)
                .padding()
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .focused($isPromptFocused)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            isPromptFocused ? Color.accentColor : Color.clear,
                            lineWidth: 2
                        )
                )
            
            // 힌트 텍스트
            if viewModel.currentPrompt.isEmpty {
                Text("예: 우주를 여행하는 귀여운 고양이")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            
            // 빠른 액션 버튼
            HStack(spacing: 8) {
                Button {
                    showPresets = true
                } label: {
                    Label("프리셋", systemImage: "sparkles.rectangle.stack")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .tint(.orange)
                
                Button {
                    viewModel.clearPrompt()
                } label: {
                    Label("지우기", systemImage: "xmark.circle")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.currentPrompt.isEmpty)
            }
        }
        .cardStyle()
        .padding(.horizontal, 4)
    }
    
    /// 스타일 선택 섹션
    private var styleSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 섹션 헤더
            HStack {
                Label("스타일", systemImage: "paintpalette")
                    .font(.headline)
                
                Spacer()
                
                Button {
                    showStyleTip.toggle()
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.secondary)
                }
            }
            
            // 스타일 옵션들
            HStack(spacing: 12) {
                ForEach(ImageStyle.allCases) { style in
                    StyleOptionButton(
                        style: style,
                        isSelected: viewModel.selectedStyle == style
                    ) {
                        viewModel.selectedStyle = style
                        HapticFeedback.selection()
                    }
                }
            }
            
            // 스타일 설명
            if showStyleTip {
                Text(viewModel.selectedStyle.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: showStyleTip)
    }
    
    /// 생성 버튼
    private var generateButton: some View {
        Button {
            viewModel.openImagePlayground()
        } label: {
            HStack(spacing: 12) {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "wand.and.sparkles")
                }
                Text("이미지 생성하기")
            }
            .frame(maxWidth: .infinity)
            .primaryButtonStyle(isEnabled: viewModel.isPromptValid)
        }
        .disabled(!viewModel.isPromptValid || viewModel.isLoading)
        .padding(.vertical, 8)
    }
    
    /// 마지막 생성 이미지 섹션
    private func lastGeneratedSection(image: GeneratedImage) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("방금 생성됨", systemImage: "sparkles")
                    .font(.headline)
                
                Spacer()
                
                Button("보기") {
                    viewModel.showImageDetail(image)
                }
                .font(.subheadline)
            }
            
            // 미리보기 카드
            HStack(spacing: 16) {
                // 이미지 썸네일
                ImageStorageManager.shared.image(for: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(image.shortPrompt)
                        .font(.subheadline)
                        .lineLimit(2)
                    
                    HStack(spacing: 6) {
                        Image(systemName: image.style.iconName)
                            .foregroundStyle(image.style.themeColor)
                        Text(image.style.displayName)
                            .foregroundStyle(.secondary)
                    }
                    .font(.caption)
                    
                    Text(image.relativeTimeString)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    /// 프리셋 섹션
    private var presetsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("추천 프리셋", systemImage: "lightbulb")
                .font(.headline)
            
            // 가로 스크롤 프리셋 카드
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(StylePreset.presets.prefix(4)) { preset in
                        PresetCard(preset: preset) {
                            viewModel.applyPreset(preset)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Image Playground 컨셉 배열
    @available(iOS 26.0, *)
    private var playgroundConcepts: [ImagePlaygroundConcept] {
        guard !viewModel.currentPrompt.isEmpty else { return [] }
        return [.text(viewModel.currentPrompt)]
    }
}

// MARK: - StyleOptionButton
// 스타일 선택 버튼

/// 스타일 옵션 버튼
struct StyleOptionButton: View {
    let style: ImageStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            isSelected
                            ? LinearGradient(
                                colors: style.gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [Color(.tertiarySystemBackground)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: style.iconName)
                        .font(.title2)
                        .foregroundStyle(isSelected ? .white : style.themeColor)
                }
                
                Text(style.displayName)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? style.themeColor : .secondary)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .animation(.spring(duration: 0.3), value: isSelected)
    }
}

// MARK: - PresetCard
// 프리셋 카드

/// 프리셋 카드 뷰
struct PresetCard: View {
    let preset: StylePreset
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                // 이모지와 이름
                HStack {
                    Text(preset.emoji)
                        .font(.title2)
                    Text(preset.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                // 프롬프트 미리보기
                Text(preset.prompt)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                // 스타일 태그
                Text(preset.style.displayName)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(preset.style.themeColor.opacity(0.15))
                    .foregroundStyle(preset.style.themeColor)
                    .clipShape(Capsule())
            }
            .frame(width: 160)
            .padding()
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - PresetPickerSheet
// 프리셋 선택 시트

/// 프리셋 선택 시트
struct PresetPickerSheet: View {
    @EnvironmentObject private var viewModel: ImageMakerViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(StylePreset.presets) { preset in
                    Button {
                        viewModel.applyPreset(preset)
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            Text(preset.emoji)
                                .font(.title)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(preset.name)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                
                                Text(preset.prompt)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            
                            Spacer()
                            
                            // 스타일 표시
                            Image(systemName: preset.style.iconName)
                                .foregroundStyle(preset.style.themeColor)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("프리셋 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Preview

#Preview {
    ImageGeneratorView()
        .environmentObject(ImageMakerViewModel())
        .environmentObject(ImageStorageManager.shared)
}
