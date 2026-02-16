import RealityKit
import Foundation

// USDZ 캐싱
// =========

class ModelCache {
    static let shared = ModelCache()
    private let cacheDirectory: URL
    
    init() {
        cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ModelCache")
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func cachedURL(for remoteURL: URL) -> URL {
        let filename = remoteURL.lastPathComponent
        return cacheDirectory.appendingPathComponent(filename)
    }
    
    func loadModel(from remoteURL: URL) async throws -> Entity {
        let localURL = cachedURL(for: remoteURL)
        
        // 캐시 확인
        if FileManager.default.fileExists(atPath: localURL.path) {
            return try await Entity(contentsOf: localURL)
        }
        
        // 다운로드 및 캐시
        let (tempURL, _) = try await URLSession.shared.download(from: remoteURL)
        try FileManager.default.moveItem(at: tempURL, to: localURL)
        
        return try await Entity(contentsOf: localURL)
    }
}
