import RealityKit
import Foundation

// 원격 USDZ 다운로드
// ==================

func downloadUSDZ(from urlString: String) async throws -> Entity {
    guard let url = URL(string: urlString) else {
        throw URLError(.badURL)
    }
    
    // 파일 다운로드
    let (localURL, _) = try await URLSession.shared.download(from: url)
    
    // 임시 디렉토리로 이동 (확장자 추가)
    let destinationURL = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)
        .appendingPathExtension("usdz")
    
    try FileManager.default.moveItem(at: localURL, to: destinationURL)
    
    // Entity 로드
    let entity = try await Entity(contentsOf: destinationURL)
    
    // 임시 파일 정리
    try? FileManager.default.removeItem(at: destinationURL)
    
    return entity
}
