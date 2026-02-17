import ARKit
import RealityKit

// 저장된 월드 맵으로 세션 시작
func restoreSession(with worldMap: ARWorldMap) {
    let configuration = ARWorldTrackingConfiguration()
    configuration.planeDetection = [.horizontal, .vertical]
    configuration.initialWorldMap = worldMap // 핵심!
    
    // 이전 세션의 앵커들이 자동으로 복원됨
    arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    
    print("월드 맵으로 세션 시작됨")
}

// 로드 및 복원 전체 프로세스
func restoreFromFile(url: URL) {
    do {
        let worldMap = try loadWorldMap(from: url)
        restoreSession(with: worldMap)
        
        // 복원된 앵커들의 Entity 재생성
        for anchor in worldMap.anchors {
            recreateEntity(for: anchor)
        }
    } catch {
        print("복원 실패: \(error)")
    }
}

func recreateEntity(for anchor: ARAnchor) {
    guard let name = anchor.name else { return }
    
    // 앵커 이름에 따라 적절한 모델 로드
    let anchorEntity = AnchorEntity(anchor: anchor)
    
    if name.contains("furniture") {
        if let model = try? ModelEntity.loadModel(named: name) {
            anchorEntity.addChild(model)
        }
    }
    
    arView.scene.addAnchor(anchorEntity)
}
