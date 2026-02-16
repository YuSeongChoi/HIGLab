import RealityKit

// CollisionComponent 사용법
// =========================

let entity = ModelEntity(
    mesh: .generateBox(size: 0.1),
    materials: [SimpleMaterial(color: .red, isMetallic: false)]
)

// 충돌 모양 생성
let collisionShape = ShapeResource.generateBox(size: [0.1, 0.1, 0.1])

// CollisionComponent 추가
entity.components.set(
    CollisionComponent(shapes: [collisionShape])
)

// 다른 충돌 모양들
let sphereShape = ShapeResource.generateSphere(radius: 0.1)
let capsuleShape = ShapeResource.generateCapsule(height: 0.2, radius: 0.05)

// 복합 충돌 모양 (여러 모양 조합)
entity.components.set(
    CollisionComponent(shapes: [
        .generateBox(size: [0.1, 0.1, 0.1]),
        .generateSphere(radius: 0.05)
    ])
)
