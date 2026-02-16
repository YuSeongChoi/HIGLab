import Vision
import Foundation

/// 분류 결과 모델
///
/// VNClassificationObservation을 앱에서 사용하기 쉬운 형태로 변환
struct ImageClassificationResult: Identifiable {
    let id = UUID()
    
    /// 최상위 분류 레이블
    let topLabel: String
    
    /// 최상위 분류 신뢰도 (0.0 ~ 1.0)
    let topConfidence: Float
    
    /// 상위 N개 결과
    let topResults: [Classification]
    
    /// 분류 시간
    let classificationTime: TimeInterval
    
    /// 유효한 결과인지 (신뢰도 임계값 기준)
    var isValid: Bool {
        topConfidence >= 0.5  // 50% 이상
    }
    
    /// 신뢰도 퍼센트 문자열
    var confidenceText: String {
        String(format: "%.1f%%", topConfidence * 100)
    }
}

/// 개별 분류 항목
struct Classification: Identifiable {
    let id = UUID()
    let label: String
    let confidence: Float
    
    var confidenceText: String {
        String(format: "%.1f%%", confidence * 100)
    }
    
    /// 신뢰도를 0~1 범위의 Progress로
    var progress: Double {
        Double(confidence)
    }
}

// MARK: - VNClassificationObservation 변환
extension ImageClassificationResult {
    
    /// VNClassificationObservation 배열에서 결과 생성
    init(from observations: [VNClassificationObservation], time: TimeInterval = 0) {
        let sorted = observations.sorted { $0.confidence > $1.confidence }
        
        self.topLabel = sorted.first?.identifier ?? "알 수 없음"
        self.topConfidence = sorted.first?.confidence ?? 0
        self.topResults = sorted.prefix(5).map { observation in
            Classification(
                label: observation.identifier,
                confidence: observation.confidence
            )
        }
        self.classificationTime = time
    }
}

// MARK: - Preview Data
extension ImageClassificationResult {
    static let preview = ImageClassificationResult(
        topLabel: "Golden Retriever",
        topConfidence: 0.923,
        topResults: [
            Classification(label: "Golden Retriever", confidence: 0.923),
            Classification(label: "Labrador Retriever", confidence: 0.045),
            Classification(label: "Cocker Spaniel", confidence: 0.012),
            Classification(label: "Irish Setter", confidence: 0.008),
            Classification(label: "Beagle", confidence: 0.005)
        ],
        classificationTime: 0.023
    )
}
