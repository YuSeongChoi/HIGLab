import RealityKit

// MARK: - Entity-Component-System (ECS) 패턴
// RealityKit의 핵심 아키텍처입니다.

/// Entity: 장면의 기본 객체
/// 빈 컨테이너로 시작하여 Component를 추가합니다.
let entity = Entity()

/// ModelEntity: 3D 모델을 표시하는 Entity
let box = ModelEntity(
    mesh: .generateBox(size: 0.1),
    materials: [SimpleMaterial(color: .blue, isMetallic: false)]
)

// Component: Entity에 기능을 추가하는 데이터
// - ModelComponent: 3D 메시와 재질
// - Transform: 위치, 회전, 크기
// - CollisionComponent: 충돌 감지
// - PhysicsBodyComponent: 물리 시뮬레이션

// 예: Transform Component 접근
var transform = entity.transform
transform.translation = [0, 1, 0]  // Y축으로 1m 위로
transform.rotation = simd_quatf(angle: .pi/4, axis: [0, 1, 0])  // 45도 회전
transform.scale = [1.5, 1.5, 1.5]  // 1.5배 확대
entity.transform = transform

// System: Component를 처리하는 로직
// RealityKit이 내부적으로 관리 (렌더링, 물리, 애니메이션 등)
