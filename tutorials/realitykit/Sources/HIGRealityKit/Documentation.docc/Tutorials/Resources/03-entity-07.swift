import RealityKit

// 여러 Component 조합하기
// =======================

func createInteractiveBox() -> ModelEntity {
    // 1. 기본 모양과 머티리얼
    let mesh = MeshResource.generateBox(size: 0.1)
    let material = SimpleMaterial(color: .orange, isMetallic: true)
    let entity = ModelEntity(mesh: mesh, materials: [material])
    entity.name = "InteractiveBox"
    
    // 2. 충돌 컴포넌트 (탭 감지, 물리 충돌용)
    entity.components.set(
        CollisionComponent(shapes: [.generateBox(size: [0.1, 0.1, 0.1])])
    )
    
    // 3. 물리 바디 (중력, 충돌 반응)
    entity.components.set(
        PhysicsBodyComponent(
            massProperties: .init(mass: 1.0),
            material: .default,
            mode: .dynamic
        )
    )
    
    // 4. 그림자 설정
    entity.components.set(GroundingShadowComponent(castsShadow: true))
    
    return entity
}
