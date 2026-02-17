import SwiftUI
import PhotosUI

// MARK: - 사진 분류 뷰
// 사진 라이브러리에서 이미지를 선택하여 분류

struct PhotoClassifyView: View {
    
    // MARK: - 환경 객체
    @EnvironmentObject private var classifier: ImageClassifier
    
    // MARK: - 상태
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: PlatformImage?
    @State private var isProcessing = false
    @State private var results: [ClassificationResult] = []
    @State private var errorMessage: String?
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 이미지 표시 영역
                imageDisplayArea
                
                // 사진 선택 버튼
                photoPickerButton
                
                // 분류 결과
                if !results.isEmpty {
                    ResultsView(results: results)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("사진 분류")
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    await loadAndClassify(item: newItem)
                }
            }
            .alert("오류", isPresented: .constant(errorMessage != nil)) {
                Button("확인") {
                    errorMessage = nil
                }
            } message: {
                if let errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    // MARK: - 이미지 표시 영역
    @ViewBuilder
    private var imageDisplayArea: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.gray.opacity(0.1))
                .frame(height: 300)
            
            if let selectedImage {
                #if canImport(UIKit)
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                #elseif canImport(AppKit)
                Image(nsImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                #endif
            } else {
                // 플레이스홀더
                VStack(spacing: 12) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                    Text("사진을 선택하세요")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
            
            // 로딩 오버레이
            if isProcessing {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("분류 중...")
                        .font(.headline)
                }
            }
        }
    }
    
    // MARK: - 사진 선택 버튼
    @ViewBuilder
    private var photoPickerButton: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            Label("사진 선택", systemImage: "photo.badge.plus")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isProcessing)
    }
    
    // MARK: - 이미지 로드 및 분류
    private func loadAndClassify(item: PhotosPickerItem?) async {
        guard let item else { return }
        
        isProcessing = true
        results = []
        
        defer { isProcessing = false }
        
        do {
            // 이미지 데이터 로드
            guard let data = try await item.loadTransferable(type: Data.self) else {
                errorMessage = "이미지를 로드할 수 없습니다"
                return
            }
            
            #if canImport(UIKit)
            guard let image = UIImage(data: data) else {
                errorMessage = "이미지 형식이 올바르지 않습니다"
                return
            }
            #elseif canImport(AppKit)
            guard let image = NSImage(data: data) else {
                errorMessage = "이미지 형식이 올바르지 않습니다"
                return
            }
            #endif
            
            selectedImage = image
            
            // 분류 수행
            results = try await classifier.classify(image: image)
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - 프리뷰
#Preview {
    PhotoClassifyView()
        .environmentObject(ImageClassifier())
}
