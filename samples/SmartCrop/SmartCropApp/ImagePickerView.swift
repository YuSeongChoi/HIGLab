// ImagePickerView.swift
// SmartCrop - HIG Lab 샘플 프로젝트
// iOS 26 ExtensibleImage API 활용

import SwiftUI
import PhotosUI

/// 이미지 선택 및 미리보기를 담당하는 뷰
/// 다양한 소스(카메라, 라이브러리, 파일)에서 이미지를 선택할 수 있습니다
struct ImagePickerView: View {
    /// 이미지 처리 모델
    @Environment(ImageProcessingModel.self) private var model
    
    /// 선택된 PhotosPickerItem
    @State private var selectedItem: PhotosPickerItem?
    
    /// 카메라 표시 여부
    @State private var showCamera = false
    
    /// 파일 피커 표시 여부
    @State private var showFilePicker = false
    
    /// 로딩 중 여부
    @State private var isLoading = false
    
    /// 오류 메시지
    @State private var errorMessage: String?
    
    /// 오류 알림 표시 여부
    @State private var showError = false
    
    var body: some View {
        VStack(spacing: 24) {
            // 이미지 미리보기 영역
            previewArea
            
            // 소스 선택 버튼들
            sourceButtons
            
            // 최근 이미지
            recentImagesSection
        }
        .padding()
        .photosPicker(
            isPresented: .constant(false),
            selection: $selectedItem,
            matching: .images
        )
        .onChange(of: selectedItem) { _, newValue in
            Task {
                await loadSelectedImage(newValue)
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView { image in
                model.loadImage(image)
            }
        }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
        .alert("오류", isPresented: $showError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "알 수 없는 오류가 발생했습니다")
        }
    }
    
    // MARK: - 미리보기 영역
    
    private var previewArea: some View {
        Group {
            if isLoading {
                // 로딩 중
                ProgressView("이미지 로딩 중...")
                    .frame(height: 200)
            } else if let image = model.originalImage {
                // 이미지 미리보기
                VStack(spacing: 12) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 4)
                    
                    // 이미지 정보
                    imageInfoView(image)
                }
            } else {
                // 빈 상태
                emptyPreview
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    /// 빈 상태 미리보기
    private var emptyPreview: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(.tertiary)
            
            Text("이미지를 선택해주세요")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("사진 라이브러리, 카메라, 또는 파일에서\n이미지를 가져올 수 있습니다")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 200)
    }
    
    /// 이미지 정보 표시
    private func imageInfoView(_ image: UIImage) -> some View {
        HStack(spacing: 20) {
            infoItem(
                icon: "aspectratio",
                title: "크기",
                value: "\(Int(image.size.width)) × \(Int(image.size.height))"
            )
            
            infoItem(
                icon: "doc",
                title: "용량",
                value: image.formattedDataSize
            )
            
            infoItem(
                icon: "aspectratio.fill",
                title: "비율",
                value: String(format: "%.2f", image.size.aspectRatio)
            )
        }
        .font(.caption)
    }
    
    /// 정보 아이템
    private func infoItem(icon: String, title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
            Text(title)
                .foregroundStyle(.tertiary)
            Text(value)
                .fontWeight(.medium)
        }
    }
    
    // MARK: - 소스 선택 버튼
    
    private var sourceButtons: some View {
        HStack(spacing: 16) {
            // 사진 라이브러리
            PhotosPicker(
                selection: $selectedItem,
                matching: .images
            ) {
                sourceButton(
                    icon: "photo.on.rectangle",
                    title: "라이브러리",
                    color: .blue
                )
            }
            
            // 카메라
            Button {
                showCamera = true
            } label: {
                sourceButton(
                    icon: "camera",
                    title: "카메라",
                    color: .green
                )
            }
            
            // 파일
            Button {
                showFilePicker = true
            } label: {
                sourceButton(
                    icon: "folder",
                    title: "파일",
                    color: .orange
                )
            }
        }
    }
    
    /// 소스 버튼 레이블
    private func sourceButton(
        icon: String,
        title: String,
        color: Color
    ) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 50, height: 50)
                .background(color.opacity(0.15), in: Circle())
                .foregroundStyle(color)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.tertiarySystemBackground))
        )
    }
    
    // MARK: - 최근 이미지
    
    @State private var recentImages: [UIImage] = []
    
    private var recentImagesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("최근 이미지")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            if recentImages.isEmpty {
                Text("최근 처리한 이미지가 없습니다")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(recentImages.indices, id: \.self) { index in
                            recentImageThumbnail(recentImages[index])
                        }
                    }
                }
            }
        }
    }
    
    /// 최근 이미지 썸네일
    private func recentImageThumbnail(_ image: UIImage) -> some View {
        Button {
            model.loadImage(image)
        } label: {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: AppConstants.thumbnailSize, height: AppConstants.thumbnailSize)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    // MARK: - 메서드
    
    /// 선택된 이미지 로드
    private func loadSelectedImage(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                let resized = image.resized(maxDimension: AppConstants.maxImageDimension)
                model.loadImage(resized)
            }
        } catch {
            errorMessage = "이미지를 불러올 수 없습니다: \(error.localizedDescription)"
            showError = true
        }
    }
    
    /// 파일 임포트 처리
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            // 보안 스코프 접근
            guard url.startAccessingSecurityScopedResource() else {
                errorMessage = "파일에 접근할 수 없습니다"
                showError = true
                return
            }
            
            defer { url.stopAccessingSecurityScopedResource() }
            
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                let resized = image.resized(maxDimension: AppConstants.maxImageDimension)
                model.loadImage(resized)
            } else {
                errorMessage = "이미지 파일을 읽을 수 없습니다"
                showError = true
            }
            
        case .failure(let error):
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

// MARK: - CGSize 확장

extension CGSize {
    /// 종횡비
    var aspectRatio: CGFloat {
        guard height > 0 else { return 0 }
        return width / height
    }
}

// MARK: - 카메라 뷰

/// 카메라 캡처 뷰
struct CameraView: UIViewControllerRepresentable {
    /// 캡처 완료 콜백
    let onCapture: (UIImage) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.onCapture(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - 미리보기

#Preview {
    ImagePickerView()
        .environment(ImageProcessingModel())
}
