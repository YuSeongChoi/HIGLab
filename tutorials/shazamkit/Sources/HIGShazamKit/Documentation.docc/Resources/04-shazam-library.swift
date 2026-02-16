import ShazamKit

/// Shazam 라이브러리 관리
class ShazamLibraryManager {
    static let shared = ShazamLibraryManager()
    
    /// 사용자의 Shazam 히스토리 가져오기
    func fetchUserHistory() async throws -> [SHMediaItem] {
        // SHLibrary.default.items로 히스토리 접근
        var items: [SHMediaItem] = []
        
        for await item in SHLibrary.default.items {
            items.append(item)
        }
        
        return items
    }
    
    /// 인식한 곡을 Shazam 라이브러리에 저장
    func saveToLibrary(_ mediaItem: SHMediaItem) async throws {
        try await SHLibrary.default.add(mediaItem)
    }
    
    /// 라이브러리에서 항목 제거
    func removeFromLibrary(_ mediaItem: SHMediaItem) async throws {
        try await SHLibrary.default.remove(mediaItem)
    }
}

// 사용 예시
func exampleUsage() async {
    do {
        // 히스토리 가져오기
        let history = try await ShazamLibraryManager.shared.fetchUserHistory()
        print("Shazam 히스토리: \(history.count)곡")
        
        // 첫 번째 곡 정보
        if let first = history.first {
            print("최근 인식: \(first.title ?? "")")
        }
    } catch {
        print("오류: \(error)")
    }
}
