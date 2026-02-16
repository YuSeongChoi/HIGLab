import RealityKit

// AnchorEntity 기본
// =================

func setupAnchor(_ arView: ARView) {
    // AnchorEntity는 장면 계층의 루트 역할
    // AR 콘텐츠를 현실 세계에 고정
    
    // 수평면 앵커
    let floorAnchor = AnchorEntity(plane: .horizontal)
    
    // 콘텐츠 추가
    let box = ModelEntity(
        mesh: .generateBox(size: 0.1),
        materials: [SimpleMaterial(color: .blue, isMetallic: true)]
    )
    floorAnchor.addChild(box)
    
    // 씬에 앵커 추가
    arView.scene.addAnchor(floorAnchor)
}
