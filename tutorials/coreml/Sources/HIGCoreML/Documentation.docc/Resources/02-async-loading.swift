import CoreML

/// 비동기 모델 로딩
///
/// 큰 모델에 권장됩니다.
/// UI가 반응성을 유지하면서 모델을 로드합니다.
actor AsyncModelLoader {
    
    private var model: MLModel?
    private var isLoading = false
    
    /// 비동기로 모델 로딩 (iOS 15+)
    func loadModel() async throws -> MLModel {
        // 이미 로딩된 경우 반환
        if let model = model {
            return model
        }
        
        // 중복 로딩 방지
        guard !isLoading else {
            throw ModelError.loadingFailed
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let configuration = MLModelConfiguration()
        configuration.computeUnits = .all
        
        // 백그라운드에서 컴파일 및 로딩
        guard let modelURL = Bundle.main.url(
            forResource: "MobileNetV2",
            withExtension: "mlmodelc"
        ) else {
            throw ModelError.modelNotFound
        }
        
        // iOS 16+: load(contentsOf:configuration:) 사용
        let loadedModel = try await MLModel.load(
            contentsOf: modelURL,
            configuration: configuration
        )
        
        self.model = loadedModel
        return loadedModel
    }
    
    /// 로딩 상태 확인
    var isModelReady: Bool {
        model != nil
    }
}

// MARK: - SwiftUI에서 사용
import SwiftUI

struct AsyncLoadingView: View {
    @State private var model: MLModel?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    let loader = AsyncModelLoader()
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("모델 로딩 중...")
            } else if let error = errorMessage {
                Text("에러: \(error)")
                    .foregroundStyle(.red)
            } else {
                Text("모델 준비 완료! ✅")
            }
        }
        .task {
            do {
                model = try await loader.loadModel()
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}
