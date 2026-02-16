import SwiftUI
import PhotosUI
import CoreML
import Vision

/// 이미지 분류 전체 화면
struct ImageClassifierScreen: View {
    @StateObject private var viewModel = ImageClassifierViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 상태 표시
                    statusBadge
                    
                    // 이미지 영역
                    imageArea
                    
                    // 결과 영역
                    if let result = viewModel.result {
                        ClassificationResultView(result: result)
                    }
                    
                    // 에러 메시지
                    if let error = viewModel.errorMessage {
                        errorView(message: error)
                    }
                }
                .padding()
            }
            .navigationTitle("이미지 분류")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    imagePickerMenu
                }
            }
        }
    }
    
    // MARK: - Status Badge
    @ViewBuilder
    private var statusBadge: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(viewModel.isModelReady ? Color.green : Color.orange)
                .frame(width: 8, height: 8)
            
            Text(viewModel.statusText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.gray.opacity(0.1))
        .clipShape(Capsule())
    }
    
    // MARK: - Image Area
    @ViewBuilder
    private var imageArea: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.08))
                .frame(height: 300)
            
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding()
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 50))
                        .foregroundStyle(.gray)
                    
                    Text("분류할 이미지를 선택하세요")
                        .foregroundStyle(.secondary)
                }
            }
            
            if viewModel.isClassifying {
                Color.black.opacity(0.3)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
            }
        }
    }
    
    // MARK: - Image Picker Menu
    @ViewBuilder
    private var imagePickerMenu: some View {
        Menu {
            PhotosPicker(
                selection: $viewModel.selectedPhotoItem,
                matching: .images
            ) {
                Label("사진첩", systemImage: "photo.on.rectangle")
            }
            
            Button {
                viewModel.showCamera = true
            } label: {
                Label("카메라", systemImage: "camera")
            }
        } label: {
            Image(systemName: "plus.circle.fill")
                .font(.title2)
        }
        .disabled(!viewModel.isModelReady)
        .fullScreenCover(isPresented: $viewModel.showCamera) {
            CameraView(capturedImage: $viewModel.cameraImage)
        }
    }
    
    // MARK: - Error View
    private func errorView(message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            Text(message)
                .font(.caption)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - ViewModel
@MainActor
class ImageClassifierViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var selectedPhotoItem: PhotosPickerItem? {
        didSet { loadSelectedPhoto() }
    }
    @Published var cameraImage: UIImage? {
        didSet { processImage(cameraImage) }
    }
    @Published var result: ImageClassificationResult?
    @Published var isClassifying = false
    @Published var isModelReady = false
    @Published var errorMessage: String?
    @Published var showCamera = false
    
    private var visionModel: VNCoreMLModel?
    
    var statusText: String {
        if isClassifying { return "분류 중..." }
        if isModelReady { return "준비됨" }
        return "모델 로딩 중..."
    }
    
    init() {
        Task { await loadModel() }
    }
    
    private func loadModel() async {
        do {
            let config = MLModelConfiguration()
            let model = try MobileNetV2(configuration: config)
            visionModel = try VNCoreMLModel(for: model.model)
            isModelReady = true
        } catch {
            errorMessage = "모델 로딩 실패: \(error.localizedDescription)"
        }
    }
    
    private func loadSelectedPhoto() {
        Task {
            guard let item = selectedPhotoItem,
                  let data = try? await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else { return }
            processImage(image)
        }
    }
    
    private func processImage(_ image: UIImage?) {
        guard let image = image else { return }
        selectedImage = image
        classify(image: image)
    }
    
    private func classify(image: UIImage) {
        guard let model = visionModel, let cgImage = image.cgImage else { return }
        
        isClassifying = true
        errorMessage = nil
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            DispatchQueue.main.async {
                self?.isClassifying = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let results = request.results as? [VNClassificationObservation] else {
                    self?.errorMessage = "결과 파싱 실패"
                    return
                }
                
                let elapsed = CFAbsoluteTimeGetCurrent() - startTime
                self?.result = ImageClassificationResult(from: results, time: elapsed)
            }
        }
        request.imageCropAndScaleOption = .centerCrop
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }
}

#Preview {
    ImageClassifierScreen()
}
