import ShazamKit

// SHMatch - 매칭 성공 결과
func exploreMatch(_ match: SHMatch) {
    // mediaItems: 인식된 곡들의 배열
    // 보통 하나지만 여러 개일 수 있음 (커스텀 카탈로그)
    for item in match.mediaItems {
        print("제목: \(item.title ?? "알 수 없음")")
        print("아티스트: \(item.artist ?? "알 수 없음")")
        print("앨범: \(item.albumTitle ?? "알 수 없음")")
    }
    
    // querySignature: 매칭에 사용된 시그니처
    let signature = match.querySignature
    print("쿼리 시그니처 길이: \(signature.duration)초")
}

// 첫 번째 매칭 결과 가져오기
func getFirstMatch(_ match: SHMatch) -> SHMatchedMediaItem? {
    return match.mediaItems.first
}
