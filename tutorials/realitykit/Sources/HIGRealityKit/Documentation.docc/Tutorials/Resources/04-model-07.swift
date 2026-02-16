import RealityKit

// 여러 모델 동시 로딩
// ===================

func loadMultipleModels() async throws -> [Entity] {
    // async let으로 병렬 로딩
    async let robot = Entity(named: "robot")
    async let car = Entity(named: "car")
    async let tree = Entity(named: "tree")
    
    // 모두 완료될 때까지 대기
    let entities = try await [robot, car, tree]
    return entities
}

// TaskGroup으로 동적 개수 로딩
func loadModelsFromList(names: [String]) async throws -> [Entity] {
    try await withThrowingTaskGroup(of: Entity.self) { group in
        for name in names {
            group.addTask {
                try await Entity(named: name)
            }
        }
        
        var results: [Entity] = []
        for try await entity in group {
            results.append(entity)
        }
        return results
    }
}
