import RealityKit

// Entity-Component-System (ECS) 패턴
// ===================================

// Entity: 장면의 기본 객체 (컨테이너 역할)
let entity = Entity()

// Component: Entity에 기능을 추가하는 데이터
// - ModelComponent: 3D 모양과 머티리얼
// - CollisionComponent: 충돌 감지
// - PhysicsBodyComponent: 물리 시뮬레이션
// - Transform: 위치, 회전, 크기

// System: Component를 처리하는 로직
// RealityKit은 렌더링, 물리, 애니메이션 시스템을 내장
