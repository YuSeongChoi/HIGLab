import RealityKit

// Entity 계층 구조
// ================

// 부모 Entity
let parentEntity = Entity()
parentEntity.name = "Parent"

// 자식 Entity들
let child1 = Entity()
child1.name = "Child1"

let child2 = Entity()
child2.name = "Child2"

// 자식 추가
parentEntity.addChild(child1)
parentEntity.addChild(child2)

// 자식의 Transform은 부모를 기준으로 적용됨
child1.position = [0.1, 0, 0]  // 부모 기준 오른쪽 10cm

// 자식 제거
// parentEntity.removeChild(child1)

// 모든 자식 순회
for child in parentEntity.children {
    print("Child: \(child.name)")
}
