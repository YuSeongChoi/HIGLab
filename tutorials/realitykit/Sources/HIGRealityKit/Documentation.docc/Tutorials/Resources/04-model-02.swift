import RealityKit

// 동기 USDZ 로딩
// ==============

func loadModelSync(_ arView: ARView) {
    do {
        // 번들에서 USDZ 파일 로드
        let modelEntity = try Entity.load(named: "toy_robot")
        
        // 앵커에 추가
        let anchor = AnchorEntity(plane: .horizontal)
        anchor.addChild(modelEntity)
        arView.scene.addAnchor(anchor)
        
    } catch {
        print("모델 로딩 실패: \(error)")
    }
}

// contentsOf로 파일 경로 지정
func loadFromPath() throws -> Entity {
    let url = Bundle.main.url(forResource: "model", withExtension: "usdz")!
    return try Entity.load(contentsOf: url)
}
