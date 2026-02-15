import RealityKit

func loadAndPlaceModel(in arView: ARView, at position: SIMD3<Float>) async {
    do {
        // USDZ 모델 로딩
        let entity = try await ModelEntity.load(named: "chair.usdz")
        
        // 앵커 생성
        let anchor = AnchorEntity(world: position)
        anchor.addChild(entity)
        
        // 씬에 추가
        arView.scene.addAnchor(anchor)
        
        // 그림자 활성화
        entity.generateCollisionShapes(recursive: true)
        arView.installGestures(.all, for: entity)
    } catch {
        print("모델 로딩 실패: \(error)")
    }
}
