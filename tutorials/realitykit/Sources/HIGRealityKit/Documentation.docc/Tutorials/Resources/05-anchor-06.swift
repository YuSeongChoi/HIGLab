import RealityKit

// 최소 평면 크기 지정
// ===================

func minimumBoundsAnchor(_ arView: ARView) {
    // 최소 40cm x 40cm 이상의 평면만
    let largeTableAnchor = AnchorEntity(
        plane: .horizontal,
        classification: .table,
        minimumBounds: SIMD2<Float>(0.4, 0.4)
    )
    
    // 최소 1m x 1m 이상의 바닥
    let floorAnchor = AnchorEntity(
        plane: .horizontal,
        classification: .floor,
        minimumBounds: SIMD2<Float>(1.0, 1.0)
    )
    
    // 너무 작은 평면은 무시되어 오탐지 방지
    let preciseAnchor = AnchorEntity(
        plane: .horizontal,
        minimumBounds: [0.2, 0.2]  // 20cm x 20cm 이상
    )
    
    arView.scene.addAnchor(preciseAnchor)
}
