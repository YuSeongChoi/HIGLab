import RealityKit

// 수직면(벽) 앵커
// ===============

func verticalPlaneAnchor(_ arView: ARView) {
    // 기본 수직면
    let wallAnchor = AnchorEntity(plane: .vertical)
    
    // 벽으로 분류된 수직면만
    let wallOnlyAnchor = AnchorEntity(plane: .vertical, classification: .wall)
    
    // 벽에 걸 포스터/그림
    let poster = ModelEntity(
        mesh: .generatePlane(width: 0.4, depth: 0.6),
        materials: [SimpleMaterial(color: .orange, isMetallic: false)]
    )
    
    // 벽에서 약간 앞으로 배치
    poster.position.z = 0.01  // 벽에서 1cm 앞
    
    wallAnchor.addChild(poster)
    arView.scene.addAnchor(wallAnchor)
}
