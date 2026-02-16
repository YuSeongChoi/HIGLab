import SwiftUI
import PhotosUI

/// 서비스를 사용하는 ContentView
struct ContentViewWithService: View {
    @StateObject private var classifier = ImageClassifierService()
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 모델 상태 표시
                modelStatusView
                
                // 이미지 영역
                imageDisplayView
                
                // 결과 표시
                resultView
                
                Spacer()
                
                // 이미지 선택
                imagePickerButton
            }
            .padding()
            .navigationTitle("이미지 분류")
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var modelStatusView: some View {
        HStack {
            Circle()
                .fill(classifier.isModelReady ? Color.green : Color.orange)
                .frame(width: 10, height: 10)
            Text(classifier.isModelReady ? "모델 준비됨" : "모델 로딩 중...")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    @ViewBuilder
    private var imageDisplayView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
                .frame(height: 300)
            
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
            } else {
                VStack {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 50))
                        .foregroundStyle(.gray)
                    Text("사진을 선택하세요")
                        .foregroundStyle(.secondary)
                }
            }
            
            if classifier.isClassifying {
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
    }
    
    @ViewBuilder
    private var resultView: some View {
        if let result = classifier.lastResult {
            VStack(spacing: 12) {
                Text(result.label)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(result.confidencePercentage)
                    .font(.title3)
                    .foregroundStyle(.blue)
                
                // 상위 5개 결과
                ForEach(result.topResults.prefix(5), id: \.identifier) { obs in
                    HStack {
                        Text(obs.identifier)
                            .lineLimit(1)
                        Spacer()
                        Text(String(format: "%.1f%%", obs.confidence * 100))
                            .foregroundStyle(.secondary)
                    }
                    .font(.caption)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        
        if let error = classifier.errorMessage {
            Text(error)
                .foregroundStyle(.red)
                .font(.caption)
        }
    }
    
    private var imagePickerButton: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images
        ) {
            Label("사진 선택", systemImage: "photo.fill")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!classifier.isModelReady)
        .onChange(of: selectedItem) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                    await classifier.classify(image: image)
                }
            }
        }
    }
}

#Preview {
    ContentViewWithService()
}
