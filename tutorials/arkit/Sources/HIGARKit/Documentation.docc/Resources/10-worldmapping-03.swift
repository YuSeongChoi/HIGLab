import ARKit

// 월드 맵을 파일로 저장
func saveWorldMap(_ worldMap: ARWorldMap) throws -> URL {
    let documentsURL = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    ).first!
    
    let timestamp = Int(Date().timeIntervalSince1970)
    let fileURL = documentsURL.appendingPathComponent("worldmap_\(timestamp).arworldmap")
    
    // NSKeyedArchiver로 아카이브
    let data = try NSKeyedArchiver.archivedData(
        withRootObject: worldMap,
        requiringSecureCoding: true
    )
    
    try data.write(to: fileURL)
    
    print("월드 맵 저장됨: \(fileURL.lastPathComponent)")
    print("파일 크기: \(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file))")
    
    return fileURL
}

// 전체 저장 프로세스
func saveCurrentSession() async {
    do {
        let worldMap = try await getCurrentWorldMap()
        let savedURL = try saveWorldMap(worldMap)
        print("저장 완료: \(savedURL)")
    } catch {
        print("저장 실패: \(error.localizedDescription)")
    }
}
