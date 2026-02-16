import RealityKit

// System 등록 및 사용
// ===================

struct HealthComponent: Component {
    var currentHealth: Float
    var maxHealth: Float
}

class HealthSystem: System {
    static let query = EntityQuery(where: .has(HealthComponent.self))
    
    required init(scene: Scene) {}
    
    func update(context: SceneUpdateContext) {
        // 로직 구현
    }
}

// App 시작 시 System 등록
func registerSystems() {
    // Component 등록 (필수)
    HealthComponent.registerComponent()
    
    // System 등록
    HealthSystem.registerSystem()
}

// ARView에서 사용
func setupScene(_ arView: ARView) {
    // 등록된 System은 자동으로 매 프레임 실행됨
    let entity = ModelEntity(mesh: .generateBox(size: 0.1), materials: [])
    entity.components.set(HealthComponent(currentHealth: 100, maxHealth: 100))
    
    let anchor = AnchorEntity(plane: .horizontal)
    anchor.addChild(entity)
    arView.scene.addAnchor(anchor)
}
