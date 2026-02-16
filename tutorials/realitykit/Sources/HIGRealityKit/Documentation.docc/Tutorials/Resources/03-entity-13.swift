import RealityKit

// Entity 복제 (Clone)
// ===================

func cloneEntity() {
    // 원본 Entity 생성
    let original = ModelEntity(
        mesh: .generateBox(size: 0.1),
        materials: [SimpleMaterial(color: .blue, isMetallic: true)]
    )
    original.name = "Original"
    original.components.set(CollisionComponent(shapes: [.generateBox(size: [0.1, 0.1, 0.1])]))
    
    // 복제 (Component도 함께 복제됨)
    let clone = original.clone(recursive: true)
    clone.name = "Clone"
    
    // 복제본 위치 변경
    clone.position = [0.2, 0, 0]
    
    // 여러 개 복제하여 배열 만들기
    let anchor = AnchorEntity(plane: .horizontal)
    for i in 0..<5 {
        let copy = original.clone(recursive: true)
        copy.position = [Float(i) * 0.15, 0, 0]
        anchor.addChild(copy)
    }
}
