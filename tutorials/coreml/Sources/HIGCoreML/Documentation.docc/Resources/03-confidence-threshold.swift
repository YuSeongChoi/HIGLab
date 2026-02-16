import Vision

/// 신뢰도 임계값 설정
///
/// 너무 낮은 신뢰도는 "알 수 없음"으로 처리
struct ConfidenceThreshold {
    
    /// 기본 임계값 (50%)
    static let defaultThreshold: Float = 0.5
    
    /// 엄격한 임계값 (80%)
    static let strictThreshold: Float = 0.8
    
    /// 느슨한 임계값 (30%)
    static let looseThreshold: Float = 0.3
    
    /// 임계값 기반 결과 판정
    static func evaluate(
        observations: [VNClassificationObservation],
        threshold: Float = defaultThreshold
    ) -> ClassificationDecision {
        guard let top = observations.first else {
            return .noResult
        }
        
        if top.confidence >= strictThreshold {
            return .confident(
                label: top.identifier,
                confidence: top.confidence
            )
        } else if top.confidence >= threshold {
            return .uncertain(
                label: top.identifier,
                confidence: top.confidence,
                alternatives: Array(observations.dropFirst().prefix(3))
            )
        } else {
            return .unknown(
                topGuess: top.identifier,
                confidence: top.confidence
            )
        }
    }
}

/// 분류 결정 타입
enum ClassificationDecision {
    /// 충분히 확신 (80% 이상)
    case confident(label: String, confidence: Float)
    
    /// 불확실하지만 유효 (50~80%)
    case uncertain(
        label: String,
        confidence: Float,
        alternatives: [VNClassificationObservation]
    )
    
    /// 알 수 없음 (50% 미만)
    case unknown(topGuess: String, confidence: Float)
    
    /// 결과 없음
    case noResult
    
    /// 사용자에게 표시할 메시지
    var displayMessage: String {
        switch self {
        case .confident(let label, let confidence):
            return "\(label) (\(String(format: "%.0f%%", confidence * 100)))"
            
        case .uncertain(let label, let confidence, let alternatives):
            let alts = alternatives.map { $0.identifier }.joined(separator: ", ")
            return "\(label)? (\(String(format: "%.0f%%", confidence * 100)))\n다른 후보: \(alts)"
            
        case .unknown(let topGuess, let confidence):
            return "확실하지 않음 (최상위 추측: \(topGuess) \(String(format: "%.0f%%", confidence * 100)))"
            
        case .noResult:
            return "분류 결과가 없습니다"
        }
    }
    
    /// 아이콘
    var icon: String {
        switch self {
        case .confident: return "checkmark.circle.fill"
        case .uncertain: return "questionmark.circle.fill"
        case .unknown: return "exclamationmark.triangle.fill"
        case .noResult: return "xmark.circle.fill"
        }
    }
}
