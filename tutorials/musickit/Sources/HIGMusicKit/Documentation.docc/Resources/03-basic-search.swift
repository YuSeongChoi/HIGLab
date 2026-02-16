import MusicKit

// MusicCatalogSearchRequest - 기본 검색

func searchSongs(term: String) async throws -> [Song] {
    // 검색 요청 생성
    var request = MusicCatalogSearchRequest(
        term: term,
        types: [Song.self]
    )
    
    // 결과 수 제한 (선택사항)
    request.limit = 25
    
    // 요청 실행
    let response = try await request.response()
    
    // Song 결과 반환
    return Array(response.songs)
}

// 사용 예시
func exampleSearch() async {
    do {
        let songs = try await searchSongs(term: "아이유")
        
        for song in songs {
            print("🎵 \(song.title) - \(song.artistName)")
        }
    } catch {
        print("검색 실패: \(error)")
    }
}
