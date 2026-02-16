import RealityKit

struct EnemyComponent: Component {}
struct HealthComponent: Component {
    var currentHealth: Float
    var maxHealth: Float
}

// EntityQuery로 특정 Component를 가진 Entity 찾기
// ================================================

func queryEntities(in scene: Scene) {
    // 단일 Component를 가진 Entity
    let enemyQuery = EntityQuery(where: .has(EnemyComponent.self))
    
    // 여러 Component를 모두 가진 Entity
    let livingEnemyQuery = EntityQuery(where: 
        .has(EnemyComponent.self) && .has(HealthComponent.self)
    )
    
    // 쿼리 실행
    scene.performQuery(enemyQuery).forEach { entity in
        print("Found enemy: \(entity.name)")
    }
    
    // HealthComponent가 있는 적들만 처리
    scene.performQuery(livingEnemyQuery).forEach { entity in
        if let health = entity.components[HealthComponent.self] {
            print("\(entity.name) has \(health.currentHealth) HP")
        }
    }
}
