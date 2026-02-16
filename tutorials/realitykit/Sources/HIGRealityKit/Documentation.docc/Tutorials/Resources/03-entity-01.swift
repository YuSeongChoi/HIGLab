import RealityKit

// Entity 기본 사용법
// ==================

// 빈 Entity 생성
let emptyEntity = Entity()

// Entity에 이름 지정
emptyEntity.name = "MyEntity"

// Entity 자체는 눈에 보이지 않음
// Component를 추가해야 기능이 생김

// ModelEntity는 Entity의 서브클래스
// 자동으로 ModelComponent가 포함됨
let boxMesh = MeshResource.generateBox(size: 0.1)
let material = SimpleMaterial(color: .red, isMetallic: false)
let boxEntity = ModelEntity(mesh: boxMesh, materials: [material])
boxEntity.name = "RedBox"
