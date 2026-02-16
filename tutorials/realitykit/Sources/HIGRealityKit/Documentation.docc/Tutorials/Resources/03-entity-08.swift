import RealityKit

// 커스텀 Component 정의
// =====================

// Component 프로토콜 채택
struct HealthComponent: Component {
    var currentHealth: Float
    var maxHealth: Float
    
    init(maxHealth: Float) {
        self.maxHealth = maxHealth
        self.currentHealth = maxHealth
    }
    
    mutating func takeDamage(_ amount: Float) {
        currentHealth = max(0, currentHealth - amount)
    }
    
    var isDead: Bool {
        currentHealth <= 0
    }
}

// Entity에 커스텀 Component 추가
let enemy = ModelEntity(
    mesh: .generateBox(size: 0.2),
    materials: [SimpleMaterial(color: .red, isMetallic: false)]
)
enemy.components.set(HealthComponent(maxHealth: 100))

// Component 접근
if var health = enemy.components[HealthComponent.self] {
    health.takeDamage(30)
    enemy.components.set(health)  // 변경 후 다시 설정
}
