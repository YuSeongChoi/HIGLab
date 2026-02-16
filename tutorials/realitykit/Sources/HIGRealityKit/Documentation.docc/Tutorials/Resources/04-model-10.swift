import SwiftUI
import RealityKit

// 완전한 원격 모델 로딩 구현
// ==========================

@MainActor
class RemoteModelLoader: ObservableObject {
    @Published var entity: Entity?
    @Published var isLoading = false
    @Published var error: Error?
    
    func load(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                let loadedEntity = try await ModelCache.shared.loadModel(from: url)
                self.entity = loadedEntity
            } catch {
                self.error = error
            }
            self.isLoading = false
        }
    }
}

struct RemoteModelView: View {
    @StateObject private var loader = RemoteModelLoader()
    let modelURL = "https://example.com/model.usdz"
    
    var body: some View {
        ZStack {
            if let entity = loader.entity {
                ARViewContainer(entity: entity)
            }
            
            if loader.isLoading {
                ProgressView()
            }
        }
        .onAppear {
            loader.load(from: modelURL)
        }
    }
}
