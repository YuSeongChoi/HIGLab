import MusicKit

// 여러 타입 동시 검색

func searchAll(term: String) async throws -> MusicCatalogSearchResponse {
    // 여러 타입을 배열로 전달
    var request = MusicCatalogSearchRequest(
        term: term,
        types: [
            Song.self,
            Album.self,
            Artist.self,
            Playlist.self
        ]
    )
    
    request.limit = 10 // 각 타입당 10개
    
    return try await request.response()
}

// 사용 예시
func multiTypeSearchExample() async throws {
    let response = try await searchAll(term: "BTS")
    
    // 한 번의 요청으로 모든 타입 결과를 얻음
    print("노래: \(response.songs.count)개")
    print("앨범: \(response.albums.count)개")
    print("아티스트: \(response.artists.count)개")
    print("플레이리스트: \(response.playlists.count)개")
}
