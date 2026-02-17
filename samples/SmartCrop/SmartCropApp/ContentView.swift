// ContentView.swift
// SmartCrop - HIG Lab 샘플 프로젝트
// iOS 26 ExtensibleImage API 활용

import SwiftUI
import PhotosUI

/// 메인 콘텐츠 뷰
/// 이미지 선택, 처리 모드 선택, 결과 표시를 담당합니다
struct ContentView: View {
    @Environment(ImageProcessingModel.self) private var model
    
    /// 사진 선택기 표시 여부
    @State private var showPhotoPicker = false
    
    /// 선택된 PhotosPickerItem
    @State private var selectedItem: PhotosPickerItem?
    
    /// 비교 뷰 표시 여부
    @State private var showComparison = false
    
    /// 공유 시트 표시 여부
    @State private var showShareSheet = false
    
    /// 저장 완료 알림 표시 여부
    @State private var showSaveAlert = false
    
    /// 저장 결과 메시지
    @State private var saveAlertMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 이미지 표시 영역
                imageDisplayArea
                
                // 하단 컨트롤 영역
                controlArea
            }
            .navigationTitle("SmartCrop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $selectedItem,
                matching: .images
            )
            .onChange(of: selectedItem) { _, newValue in
                Task {
                    await loadImage(from: newValue)
                }
            }
            .sheet(isPresented: $showComparison) {
                if let original = model.originalImage,
                   let processed = model.processedImage {
                    ComparisonView(
                        originalImage: original,
                        processedImage: processed
                    )
                }
            }
            .alert("저장 결과", isPresented: $showSaveAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(saveAlertMessage)
            }
        }
    }
    
    // MARK: - 이미지 표시 영역
    
    @ViewBuilder
    private var imageDisplayArea: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경 그라데이션
                backgroundGradient
                
                if model.state.isProcessing {
                    // 처리 중 표시
                    ProcessingView(state: model.state)
                } else if let displayImage = model.processedImage ?? model.originalImage {
                    // 이미지 표시
                    imageView(displayImage, in: geometry.size)
                } else {
                    // 이미지 없음 - 선택 유도
                    emptyStateView
                }
            }
        }
    }
    
    /// 배경 그라데이션
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color(.secondarySystemBackground)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    /// 이미지 뷰
    private func imageView(_ image: UIImage, in size: CGSize) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: size.width, maxHeight: size.height)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.2), radius: 10)
            .padding()
            .transition(.opacity.combined(with: .scale))
            .animation(.easeInOut, value: model.processedImage)
    }
    
    /// 이미지 없을 때 표시
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)
            
            Text("이미지를 선택해주세요")
                .font(.title2)
                .foregroundStyle(.secondary)
            
            Button {
                showPhotoPicker = true
            } label: {
                Label("사진 선택", systemImage: "photo.badge.plus")
                    .font(.headline)
                    .padding()
                    .background(.tint, in: Capsule())
                    .foregroundStyle(.white)
            }
        }
    }
    
    // MARK: - 컨트롤 영역
    
    private var controlArea: some View {
        VStack(spacing: 16) {
            // 모드 선택
            if model.hasOriginalImage {
                modeSelector
            }
            
            // 액션 버튼들
            actionButtons
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    /// 처리 모드 선택기
    @ViewBuilder
    private var modeSelector: some View {
        @Bindable var bindableModel = model
        
        VStack(alignment: .leading, spacing: 8) {
            Text("처리 모드")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Picker("처리 모드", selection: $bindableModel.selectedMode) {
                ForEach(ProcessingMode.allCases) { mode in
                    Label(mode.rawValue, systemImage: mode.iconName)
                        .tag(mode)
                }
            }
            .pickerStyle(.segmented)
            
            // 선택된 모드 설명
            Text(model.selectedMode.description)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }
    
    /// 액션 버튼들
    private var actionButtons: some View {
        HStack(spacing: 12) {
            // 이미지 선택 버튼
            Button {
                showPhotoPicker = true
            } label: {
                Label("선택", systemImage: "photo")
            }
            .buttonStyle(.bordered)
            
            if model.hasOriginalImage {
                // 처리 버튼
                Button {
                    Task {
                        await model.processImage()
                    }
                } label: {
                    Label("처리", systemImage: "wand.and.stars")
                }
                .buttonStyle(.borderedProminent)
                .disabled(model.state.isProcessing)
                
                // 결과가 있을 때 추가 버튼들
                if model.hasProcessedImage {
                    // 비교 버튼
                    Button {
                        showComparison = true
                    } label: {
                        Label("비교", systemImage: "rectangle.on.rectangle")
                    }
                    .buttonStyle(.bordered)
                    
                    // 저장 버튼
                    Button {
                        Task {
                            await saveImage()
                        }
                    } label: {
                        Label("저장", systemImage: "square.and.arrow.down")
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }
    
    // MARK: - 툴바
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            if model.canUndo {
                Button {
                    model.undo()
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                }
                .accessibilityLabel(AccessibilityLabels.undoAction)
            }
            
            if model.hasOriginalImage {
                Button {
                    model.reset()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                }
                .accessibilityLabel(AccessibilityLabels.resetAction)
            }
            
            if model.hasProcessedImage {
                ShareLink(
                    item: ShareableImage(image: model.processedImage!),
                    preview: SharePreview(
                        "SmartCrop 결과",
                        image: Image(uiImage: model.processedImage!)
                    )
                ) {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel(AccessibilityLabels.shareImage)
            }
        }
    }
    
    // MARK: - 메서드
    
    /// PhotosPickerItem에서 이미지 로드
    private func loadImage(from item: PhotosPickerItem?) async {
        guard let item else { return }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                // 큰 이미지는 리사이즈
                let resizedImage = uiImage.resized(
                    maxDimension: AppConstants.maxImageDimension
                )
                model.loadImage(resizedImage)
            }
        } catch {
            print("이미지 로드 실패: \(error)")
        }
    }
    
    /// 이미지 저장
    private func saveImage() async {
        guard let image = model.processedImage else { return }
        
        let saver = PhotoLibrarySaver()
        do {
            try await saver.saveToPhotoLibrary(image)
            saveAlertMessage = "이미지가 사진 라이브러리에 저장되었습니다"
        } catch {
            saveAlertMessage = error.localizedDescription
        }
        showSaveAlert = true
    }
}

// MARK: - 미리보기

#Preview {
    ContentView()
        .environment(ImageProcessingModel())
}
