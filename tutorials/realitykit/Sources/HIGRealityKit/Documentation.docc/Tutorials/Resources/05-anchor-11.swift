import RealityKit

// 월드 앵커 (특정 좌표)
// =====================

func worldAnchor(_ arView: ARView) {
    // 특정 3D 좌표에 앵커 배치
    let worldAnchor = AnchorEntity(world: SIMD3<Float>(0, 0, -1))
    // 카메라 앞 1m 위치
    
    // Transform으로 세밀한 제어
    var transform = Transform.identity
    transform.translation = SIMD3<Float>(0.5, 0, -2)  // 오른쪽 50cm, 앞 2m
    transform.rotation = simd_quatf(angle: .pi / 4, axis: [0, 1, 0])
    
    let positionedAnchor = AnchorEntity(world: transform.matrix)
    
    // 콘텐츠 추가
    let marker = ModelEntity(
        mesh: .generateSphere(radius: 0.05),
        materials: [SimpleMaterial(color: .yellow, isMetallic: true)]
    )
    worldAnchor.addChild(marker)
    
    arView.scene.addAnchor(worldAnchor)
}
