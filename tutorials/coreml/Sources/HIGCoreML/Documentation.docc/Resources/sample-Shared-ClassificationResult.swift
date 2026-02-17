import Foundation

// MARK: - 분류 결과 모델
// 이미지 분류 결과를 담는 구조체

/// 단일 분류 결과
struct ClassificationResult: Identifiable, Hashable {
    let id = UUID()
    
    /// 분류 라벨 (예: "golden retriever", "tabby cat")
    let label: String
    
    /// 신뢰도 (0.0 ~ 1.0)
    let confidence: Float
    
    /// 신뢰도를 퍼센트 문자열로 변환
    var confidencePercentage: String {
        String(format: "%.1f%%", confidence * 100)
    }
    
    /// 신뢰도 레벨 (UI 표시용)
    var confidenceLevel: ConfidenceLevel {
        switch confidence {
        case 0.8...1.0:
            return .high
        case 0.5..<0.8:
            return .medium
        default:
            return .low
        }
    }
}

// MARK: - 신뢰도 레벨
enum ConfidenceLevel {
    case high    // 80% 이상
    case medium  // 50% ~ 80%
    case low     // 50% 미만
    
    /// 레벨에 따른 색상명
    var colorName: String {
        switch self {
        case .high: return "green"
        case .medium: return "orange"
        case .low: return "red"
        }
    }
}

// MARK: - 분류 상태
/// 분류 작업의 현재 상태
enum ClassificationState: Equatable {
    case idle           // 대기 중
    case loading        // 모델 로딩 중
    case classifying    // 분류 진행 중
    case success([ClassificationResult])  // 분류 완료
    case failure(String) // 오류 발생
    
    static func == (lhs: ClassificationState, rhs: ClassificationState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.classifying, .classifying):
            return true
        case (.success(let l), .success(let r)):
            return l == r
        case (.failure(let l), .failure(let r)):
            return l == r
        default:
            return false
        }
    }
}
