import RealityKit

// 이름으로 Entity 찾기
// ====================

func findEntityByName(_ arView: ARView) {
    // 특정 앵커에서 이름으로 찾기
    if let anchor = arView.scene.anchors.first {
        // 직접 자식에서 찾기
        let found = anchor.findEntity(named: "MyBox")
        
        // 재귀적으로 모든 자손에서 찾기 (기본값)
        let foundRecursive = anchor.findEntity(named: "DeepChild")
        
        if let entity = found {
            print("Found entity: \(entity.name)")
        }
    }
    
    // 모든 앵커에서 검색
    for anchor in arView.scene.anchors {
        if let target = anchor.findEntity(named: "Target") {
            // 찾음!
            target.position.y += 0.1
            break
        }
    }
}
