import RealityKit

// 수평면 앵커
// ===========

func horizontalPlaneAnchor(_ arView: ARView) {
    // 기본 수평면 (바닥, 테이블 등)
    let anchor1 = AnchorEntity(plane: .horizontal)
    
    // 바닥만
    let anchor2 = AnchorEntity(plane: .horizontal, classification: .floor)
    
    // 테이블만
    let anchor3 = AnchorEntity(plane: .horizontal, classification: .table)
    
    // 천장 (위쪽을 향한 면)
    let anchor4 = AnchorEntity(plane: .horizontal, classification: .ceiling)
    
    // 콘텐츠 추가
    let sphere = ModelEntity(
        mesh: .generateSphere(radius: 0.05),
        materials: [SimpleMaterial(color: .green, isMetallic: false)]
    )
    anchor1.addChild(sphere)
    
    arView.scene.addAnchor(anchor1)
}
