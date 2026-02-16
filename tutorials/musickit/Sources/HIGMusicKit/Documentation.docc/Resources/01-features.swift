import MusicKit

// MusicKit의 핵심 기능
struct MusicKitFeatures {
    
    // 1. Apple Music 카탈로그 검색
    func searchCatalog() async throws -> [Song] {
        var request = MusicCatalogSearchRequest(
            term: "아이유",
            types: [Song.self]
        )
        let response = try await request.response()
        return Array(response.songs)
    }
    
    // 2. 사용자 라이브러리 접근
    func getLibrarySongs() async throws -> [Song] {
        let request = MusicLibraryRequest<Song>()
        let response = try await request.response()
        return Array(response.items)
    }
    
    // 3. 음악 재생
    func playSong(_ song: Song) async throws {
        let player = ApplicationMusicPlayer.shared
        player.queue = [song]
        try await player.play()
    }
    
    // 4. 개인화된 추천
    func getRecommendations() async throws {
        let request = MusicPersonalRecommendationsRequest()
        let response = try await request.response()
        // response.recommendations 활용
    }
}
