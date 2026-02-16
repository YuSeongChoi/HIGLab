import RealityKit

// 여러 앵커 사용
// ==============

func setupMultipleAnchors(_ arView: ARView) {
    // 바닥 앵커 (가구 배치용)
    let floorAnchor = AnchorEntity(plane: .horizontal, classification: .floor)
    let table = ModelEntity(mesh: .generateBox(size: [0.5, 0.05, 0.5]), materials: [])
    floorAnchor.addChild(table)
    
    // 벽 앵커 (그림 걸기용)
    let wallAnchor = AnchorEntity(plane: .vertical, classification: .wall)
    let frame = ModelEntity(mesh: .generatePlane(width: 0.3, depth: 0.4), materials: [])
    wallAnchor.addChild(frame)
    
    // 테이블 위 앵커 (물건 올려놓기)
    let tableAnchor = AnchorEntity(plane: .horizontal, classification: .table)
    let cup = ModelEntity(mesh: .generateCylinder(height: 0.1, radius: 0.03), materials: [])
    tableAnchor.addChild(cup)
    
    // 모든 앵커를 씬에 추가
    arView.scene.anchors.append(contentsOf: [floorAnchor, wallAnchor, tableAnchor])
}
