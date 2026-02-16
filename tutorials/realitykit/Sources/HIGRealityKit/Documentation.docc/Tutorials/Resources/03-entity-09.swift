import RealityKit

// 커스텀 System 정의
// ==================

struct HealthComponent: Component {
    var currentHealth: Float
    var maxHealth: Float
}

// System: 특정 Component를 가진 Entity들을 매 프레임 처리
class HealthSystem: System {
    
    // 이 System이 처리할 Component 타입
    static let query = EntityQuery(where: .has(HealthComponent.self))
    
    required init(scene: Scene) {
        // 초기화
    }
    
    func update(context: SceneUpdateContext) {
        // 매 프레임 호출
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard var health = entity.components[HealthComponent.self] else { continue }
            
            // 예: 시간에 따라 체력 회복
            if health.currentHealth < health.maxHealth {
                health.currentHealth += 0.1 * Float(context.deltaTime)
                entity.components.set(health)
            }
        }
    }
}
