import Foundation

// ============================================
// 영화 데이터 모델
// ============================================

// Codable 채택 필수 - 네트워크 전송을 위해
struct Movie: Codable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String?
    let releaseYear: Int
    let runtime: Int  // 분 단위
    let posterURL: URL?
    let videoURL: URL
    
    // 편의 생성자
    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String? = nil,
        releaseYear: Int,
        runtime: Int,
        posterURL: URL? = nil,
        videoURL: URL
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.releaseYear = releaseYear
        self.runtime = runtime
        self.posterURL = posterURL
        self.videoURL = videoURL
    }
}

// 샘플 데이터
extension Movie {
    static let sample = Movie(
        title: "우주 대모험",
        subtitle: "Episode I",
        releaseYear: 2024,
        runtime: 120,
        posterURL: URL(string: "https://example.com/poster.jpg"),
        videoURL: URL(string: "https://example.com/movie.mp4")!
    )
    
    static let sampleList: [Movie] = [
        Movie(
            title: "우주 대모험",
            releaseYear: 2024,
            runtime: 120,
            videoURL: URL(string: "https://example.com/movie1.mp4")!
        ),
        Movie(
            title: "바다 속 세계",
            releaseYear: 2023,
            runtime: 95,
            videoURL: URL(string: "https://example.com/movie2.mp4")!
        ),
        Movie(
            title: "산 정상에서",
            releaseYear: 2024,
            runtime: 110,
            videoURL: URL(string: "https://example.com/movie3.mp4")!
        )
    ]
}
