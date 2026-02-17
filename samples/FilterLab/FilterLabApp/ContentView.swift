// ContentView.swift
// FilterLab - 메인 콘텐츠 뷰
// HIG Lab 샘플 프로젝트

import SwiftUI
import PhotosUI

// MARK: - 메인 콘텐츠 뷰
struct ContentView: View {
    @State private var appState = AppState()
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showPhotoPicker = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 배경
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if appState.processor.originalImage != nil {
                    // 이미지가 있을 때: 에디터 뷰
                    editorView
                } else {
                    // 이미지가 없을 때: 빈 상태
                    emptyStateView
                }
            }
            .navigationTitle("FilterLab")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $selectedPhotoItem,
                matching: .images
            )
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    await loadImage(from: newItem)
                }
            }
            .sheet(isPresented: $appState.showPresets) {
                PresetSheet(appState: appState)
            }
            .sheet(isPresented: $appState.showFilterPicker) {
                FilterPickerSheet(appState: appState)
            }
            .alert("저장 완료", isPresented: $appState.showSaveSuccess) {
                Button("확인", role: .cancel) { }
            } message: {
                Text("이미지가 사진 라이브러리에 저장되었습니다.")
            }
            .alert("오류", isPresented: $appState.showError) {
                Button("확인", role: .cancel) { }
            } message: {
                Text(appState.processor.errorMessage ?? "알 수 없는 오류가 발생했습니다.")
            }
        }
    }
    
    // MARK: - 빈 상태 뷰
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)
            
            Text("사진을 선택하여\n필터를 적용해보세요")
                .font(.title2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showPhotoPicker = true
            } label: {
                Label("사진 선택", systemImage: "photo.badge.plus")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    // MARK: - 에디터 뷰
    private var editorView: some View {
        VStack(spacing: 0) {
            // 이미지 프리뷰 영역
            ImagePreviewView(appState: appState)
            
            Divider()
            
            // 필터 컨트롤 영역
            FilterControlsView(appState: appState)
        }
    }
    
    // MARK: - 툴바
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            if appState.processor.originalImage != nil {
                Button {
                    showPhotoPicker = true
                } label: {
                    Image(systemName: "photo.badge.plus")
                }
            }
        }
        
        ToolbarItemGroup(placement: .topBarTrailing) {
            if appState.processor.originalImage != nil {
                // 프리셋 버튼
                Button {
                    appState.showPresets = true
                } label: {
                    Image(systemName: "wand.and.stars")
                }
                
                // 초기화 버튼
                Menu {
                    Button(role: .destructive) {
                        appState.filterChain.clearAll()
                        appState.processor.reset()
                    } label: {
                        Label("모든 필터 제거", systemImage: "trash")
                    }
                    
                    Button {
                        appState.processor.setImage(nil)
                        appState.filterChain.clearAll()
                    } label: {
                        Label("새 이미지 선택", systemImage: "arrow.counterclockwise")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                
                // 저장 버튼
                Button {
                    saveImage()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
                .disabled(appState.processor.isProcessing)
            }
        }
    }
    
    // MARK: - 이미지 로드
    private func loadImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    appState.processor.setImage(uiImage)
                    appState.filterChain.clearAll()
                }
            }
        } catch {
            await MainActor.run {
                appState.processor.errorMessage = "이미지 로드 실패: \(error.localizedDescription)"
                appState.showError = true
            }
        }
    }
    
    // MARK: - 이미지 저장
    private func saveImage() {
        appState.processor.saveToPhotoLibrary { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    appState.showSaveSuccess = true
                case .failure(let error):
                    appState.processor.errorMessage = error.localizedDescription
                    appState.showError = true
                }
            }
        }
    }
}

// MARK: - 프리셋 시트
struct PresetSheet: View {
    let appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(FilterPreset.allPresets) { preset in
                Button {
                    appState.filterChain.applyPreset(preset)
                    Task {
                        await appState.processor.applyFilters(chain: appState.filterChain)
                    }
                    dismiss()
                } label: {
                    Label(preset.name, systemImage: preset.icon)
                        .foregroundStyle(.primary)
                }
            }
            .navigationTitle("프리셋")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - 필터 선택 시트
struct FilterPickerSheet: View {
    let appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: FilterCategory = .color
    
    private var filteredTypes: [FilterType] {
        FilterType.allCases.filter { $0.category == selectedCategory }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 카테고리 피커
                Picker("카테고리", selection: $selectedCategory) {
                    ForEach(FilterCategory.allCases) { category in
                        Label(category.rawValue, systemImage: category.icon)
                            .tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // 필터 목록
                List(filteredTypes) { filterType in
                    Button {
                        appState.filterChain.addFilter(filterType)
                        Task {
                            await appState.processor.applyFilters(chain: appState.filterChain)
                        }
                        dismiss()
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(filterType.rawValue)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text(filterType.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("필터 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.large])
    }
}

// MARK: - 프리뷰
#Preview {
    ContentView()
}
