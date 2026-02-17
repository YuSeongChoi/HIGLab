import ARKit

// 현재 세션에서 월드 맵 가져오기
func getCurrentWorldMap() async throws -> ARWorldMap {
    return try await withCheckedThrowingContinuation { continuation in
        arView.session.getCurrentWorldMap { worldMap, error in
            if let error = error {
                continuation.resume(throwing: error)
                return
            }
            
            guard let worldMap = worldMap else {
                continuation.resume(throwing: NSError(
                    domain: "WorldMap",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "월드 맵을 가져올 수 없습니다"]
                ))
                return
            }
            
            print("월드 맵 획득 성공")
            print("앵커 수: \(worldMap.anchors.count)")
            print("특징점 수: \(worldMap.rawFeaturePoints?.points.count ?? 0)")
            
            continuation.resume(returning: worldMap)
        }
    }
}
