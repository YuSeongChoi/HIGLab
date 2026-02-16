import RealityKit

// ModelComponent 사용법
// =====================

// 방법 1: ModelEntity 사용 (권장)
let mesh = MeshResource.generateSphere(radius: 0.1)
let material = SimpleMaterial(color: .blue, isMetallic: true)
let sphereEntity = ModelEntity(mesh: mesh, materials: [material])

// 방법 2: 일반 Entity에 ModelComponent 추가
let entity = Entity()
let boxMesh = MeshResource.generateBox(size: 0.1)
let modelComponent = ModelComponent(
    mesh: boxMesh,
    materials: [SimpleMaterial(color: .green, isMetallic: false)]
)
entity.components.set(modelComponent)

// 기본 제공 메시 타입
let _ = MeshResource.generateBox(size: 0.1)
let _ = MeshResource.generateSphere(radius: 0.1)
let _ = MeshResource.generatePlane(width: 1, depth: 1)
let _ = MeshResource.generateCone(height: 0.2, radius: 0.1)
let _ = MeshResource.generateCylinder(height: 0.2, radius: 0.1)
