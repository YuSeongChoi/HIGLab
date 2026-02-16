import MusicKit

// MusicCatalogSearchResponse - 검색 결과 타입별 접근

func processSearchResponse(_ response: MusicCatalogSearchResponse) {
    // 노래 결과
    print("=== 노래 (\(response.songs.count)개) ===")
    for song in response.songs.prefix(5) {
        print("🎵 \(song.title) by \(song.artistName)")
    }
    
    // 앨범 결과
    print("\n=== 앨범 (\(response.albums.count)개) ===")
    for album in response.albums.prefix(5) {
        print("💿 \(album.title) by \(album.artistName)")
    }
    
    // 아티스트 결과
    print("\n=== 아티스트 (\(response.artists.count)개) ===")
    for artist in response.artists.prefix(5) {
        print("🎤 \(artist.name)")
    }
    
    // 플레이리스트 결과
    print("\n=== 플레이리스트 (\(response.playlists.count)개) ===")
    for playlist in response.playlists.prefix(5) {
        print("📝 \(playlist.name)")
    }
}
