import RealityKit

// 비동기 USDZ 로딩 (async/await)
// ==============================

func loadModelAsync(_ arView: ARView) async {
    do {
        // 비동기 로딩 (UI 스레드 차단 안 함)
        let entity = try await Entity(named: "large_model")
        
        // MainActor에서 씬에 추가
        await MainActor.run {
            let anchor = AnchorEntity(plane: .horizontal)
            anchor.addChild(entity)
            arView.scene.addAnchor(anchor)
        }
        
    } catch {
        print("비동기 로딩 실패: \(error)")
    }
}

// Task로 감싸서 호출
func startLoading(_ arView: ARView) {
    Task {
        await loadModelAsync(arView)
    }
}
