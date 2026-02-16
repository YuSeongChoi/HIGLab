import SwiftUI
import RealityKit

// 로딩 상태 UI
// ============

struct ModelLoaderView: View {
    @State private var isLoading = false
    @State private var loadedEntity: Entity?
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            ARViewContainer(entity: loadedEntity)
            
            if isLoading {
                ProgressView("모델 로딩 중...")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
            }
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .task {
            await loadModel()
        }
    }
    
    func loadModel() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            loadedEntity = try await Entity(named: "robot")
        } catch {
            errorMessage = "로딩 실패: \(error.localizedDescription)"
        }
    }
}
