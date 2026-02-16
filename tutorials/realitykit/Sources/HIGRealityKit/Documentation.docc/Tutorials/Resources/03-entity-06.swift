import RealityKit

// PhysicsBodyComponent 사용법
// ===========================

let entity = ModelEntity(
    mesh: .generateBox(size: 0.1),
    materials: [SimpleMaterial(color: .blue, isMetallic: false)]
)

// 충돌 컴포넌트 먼저 추가 (필수)
entity.components.set(
    CollisionComponent(shapes: [.generateBox(size: [0.1, 0.1, 0.1])])
)

// 동적 물리 바디 (중력, 충돌 영향을 받음)
entity.components.set(
    PhysicsBodyComponent(
        massProperties: .default,
        material: .default,
        mode: .dynamic
    )
)

// 정적 물리 바디 (움직이지 않음 - 바닥, 벽)
// mode: .static

// 키네마틱 (코드로만 움직임)
// mode: .kinematic
