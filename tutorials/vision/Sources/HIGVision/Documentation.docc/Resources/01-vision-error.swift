import Foundation

enum VisionError: LocalizedError {
    case invalidImage
    case requestFailed(Error)
    case noResults
    case processingFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "유효하지 않은 이미지입니다."
        case .requestFailed(let error):
            return "Vision 요청 실패: \(error.localizedDescription)"
        case .noResults:
            return "분석 결과가 없습니다."
        case .processingFailed(let message):
            return "처리 실패: \(message)"
        }
    }
}
