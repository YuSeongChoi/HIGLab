import GroupActivities
import SwiftUI
import LinkPresentation

struct WatchTogetherActivity: GroupActivity {
    let movie: Movie
    
    var metadata: GroupActivityMetadata {
        var meta = GroupActivityMetadata()
        meta.title = movie.title
        meta.subtitle = "\(movie.releaseYear)년"
        meta.type = .watchTogether
        
        // ============================================
        // 미리보기 이미지 설정
        // ============================================
        
        // 방법 1: URL에서 이미지 로드 (비동기)
        if let posterURL = movie.posterURL {
            meta.previewImage = loadImage(from: posterURL)
        }
        
        // 방법 2: 앱 번들의 이미지 사용
        // meta.previewImage = UIImage(named: "movie-poster")?.cgImage
        
        return meta
    }
    
    // 이미지 로드 헬퍼
    private func loadImage(from url: URL) -> CGImage? {
        // 실제로는 비동기로 로드해야 함
        // 여기서는 간단한 예시
        guard let data = try? Data(contentsOf: url),
              let uiImage = UIImage(data: data),
              let cgImage = uiImage.cgImage else {
            return nil
        }
        return cgImage
    }
}

// ⚠️ 참고:
// previewImage는 SharePlay 시트에 표시되는 썸네일입니다.
// 적절한 크기의 이미지를 사용하세요 (권장: 300x450px)
