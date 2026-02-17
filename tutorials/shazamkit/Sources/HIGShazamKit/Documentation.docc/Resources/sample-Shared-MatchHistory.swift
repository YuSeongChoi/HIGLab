import Foundation

// MARK: - MatchHistory
// 인식된 곡 기록을 관리하는 싱글톤

@MainActor
@Observable
final class MatchHistory {
    // MARK: - 싱글톤
    static let shared = MatchHistory()
    
    // MARK: - 프로퍼티
    private(set) var songs: [MatchedSong] = []
    
    // UserDefaults 키
    private let storageKey = "matchedSongsHistory"
    
    // MARK: - 초기화
    private init() {
        load()
    }
    
    // MARK: - 곡 추가
    func add(_ song: MatchedSong) {
        // 중복 체크 (같은 Shazam ID면 최신으로 업데이트)
        if let existingIndex = songs.firstIndex(where: { $0.shazamID == song.shazamID && song.shazamID != nil }) {
            songs.remove(at: existingIndex)
        }
        
        // 맨 앞에 추가 (최신순)
        songs.insert(song, at: 0)
        save()
    }
    
    // MARK: - 곡 삭제
    func remove(_ song: MatchedSong) {
        songs.removeAll { $0.id == song.id }
        save()
    }
    
    // MARK: - 특정 인덱스 삭제
    func remove(at offsets: IndexSet) {
        songs.remove(atOffsets: offsets)
        save()
    }
    
    // MARK: - 전체 삭제
    func clear() {
        songs.removeAll()
        save()
    }
    
    // MARK: - 저장
    private func save() {
        do {
            let data = try JSONEncoder().encode(songs)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("기록 저장 실패: \(error)")
        }
    }
    
    // MARK: - 불러오기
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return
        }
        
        do {
            songs = try JSONDecoder().decode([MatchedSong].self, from: data)
        } catch {
            print("기록 불러오기 실패: \(error)")
        }
    }
}

// MARK: - 날짜별 그룹화
extension MatchHistory {
    // 날짜별로 그룹화된 곡 목록
    var groupedByDate: [(date: String, songs: [MatchedSong])] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateStyle = .medium
        
        let grouped = Dictionary(grouping: songs) { song in
            formatter.string(from: song.matchedAt)
        }
        
        return grouped
            .map { (date: $0.key, songs: $0.value) }
            .sorted { $0.songs.first?.matchedAt ?? .distantPast > $1.songs.first?.matchedAt ?? .distantPast }
    }
}
