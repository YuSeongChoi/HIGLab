import Foundation

/// 인식 히스토리 관리
@Observable
class SongHistory {
    private(set) var songs: [Song] = []
    private let maxHistory = 100
    
    /// 새 곡 추가 (중복 제거)
    func add(_ song: Song) {
        // 이미 있는 곡인지 확인
        if let existingIndex = songs.firstIndex(where: { $0.id == song.id }) {
            // 기존 항목 제거하고 맨 앞에 추가
            songs.remove(at: existingIndex)
        }
        
        songs.insert(song, at: 0)
        
        // 최대 개수 제한
        if songs.count > maxHistory {
            songs = Array(songs.prefix(maxHistory))
        }
        
        // 저장
        save()
    }
    
    /// 특정 곡 제거
    func remove(_ song: Song) {
        songs.removeAll { $0.id == song.id }
        save()
    }
    
    /// 전체 삭제
    func clear() {
        songs.removeAll()
        save()
    }
    
    // MARK: - Persistence
    private let storageKey = "song_history"
    
    func save() {
        if let data = try? JSONEncoder().encode(songs) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    func load() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Song].self, from: data) {
            songs = decoded
        }
    }
}
