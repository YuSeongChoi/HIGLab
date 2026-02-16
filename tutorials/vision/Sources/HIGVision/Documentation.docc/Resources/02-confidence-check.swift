import Vision

extension TextRecognizer {
    
    /// 신뢰도가 높은 텍스트만 추출
    func extractHighConfidenceText(
        from observations: [VNRecognizedTextObservation],
        minConfidence: Float = 0.5
    ) -> [RecognizedText] {
        return observations.compactMap { observation in
            guard let candidate = observation.topCandidates(1).first,
                  candidate.confidence >= minConfidence else {
                return nil
            }
            
            return RecognizedText(
                text: candidate.string,
                confidence: candidate.confidence,
                boundingBox: observation.boundingBox
            )
        }
    }
    
    /// 신뢰도별로 그룹화
    func groupByConfidence(_ observations: [VNRecognizedTextObservation]) -> (high: [String], medium: [String], low: [String]) {
        var high: [String] = []
        var medium: [String] = []
        var low: [String] = []
        
        for observation in observations {
            guard let candidate = observation.topCandidates(1).first else { continue }
            
            switch candidate.confidence {
            case 0.8...1.0:
                high.append(candidate.string)
            case 0.5..<0.8:
                medium.append(candidate.string)
            default:
                low.append(candidate.string)
            }
        }
        
        return (high, medium, low)
    }
}
