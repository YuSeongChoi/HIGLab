import ARKit

// 파일에서 월드 맵 로드
func loadWorldMap(from url: URL) throws -> ARWorldMap {
    let data = try Data(contentsOf: url)
    
    guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(
        ofClass: ARWorldMap.self,
        from: data
    ) else {
        throw NSError(
            domain: "WorldMap",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "월드 맵 언아카이브 실패"]
        )
    }
    
    print("월드 맵 로드됨")
    print("저장된 앵커: \(worldMap.anchors.count)개")
    
    // 저장된 앵커들 확인
    for anchor in worldMap.anchors {
        if let name = anchor.name {
            print("  - \(name): \(type(of: anchor))")
        }
    }
    
    return worldMap
}

// 저장된 모든 월드 맵 목록 가져오기
func listSavedWorldMaps() -> [URL] {
    let documentsURL = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    ).first!
    
    let files = try? FileManager.default.contentsOfDirectory(
        at: documentsURL,
        includingPropertiesForKeys: nil
    )
    
    return files?.filter { $0.pathExtension == "arworldmap" } ?? []
}
