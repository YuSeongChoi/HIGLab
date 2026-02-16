import Vision

/// 분류 결과 파싱
///
/// VNClassificationObservation 배열에서 유용한 정보를 추출
struct ResultParser {
    
    /// 상위 N개 결과 추출
    func topResults(
        from observations: [VNClassificationObservation],
        count: Int = 5
    ) -> [Classification] {
        observations
            .sorted { $0.confidence > $1.confidence }
            .prefix(count)
            .map { Classification(label: $0.identifier, confidence: $0.confidence) }
    }
    
    /// 최상위 결과만 추출
    func topResult(from observations: [VNClassificationObservation]) -> Classification? {
        guard let top = observations.max(by: { $0.confidence < $1.confidence }) else {
            return nil
        }
        return Classification(label: top.identifier, confidence: top.confidence)
    }
    
    /// 임계값 이상인 결과만 필터링
    func validResults(
        from observations: [VNClassificationObservation],
        threshold: Float = 0.5
    ) -> [Classification] {
        observations
            .filter { $0.confidence >= threshold }
            .sorted { $0.confidence > $1.confidence }
            .map { Classification(label: $0.identifier, confidence: $0.confidence) }
    }
    
    /// 특정 레이블 검색
    func findLabel(
        _ label: String,
        in observations: [VNClassificationObservation]
    ) -> Classification? {
        guard let observation = observations.first(where: {
            $0.identifier.lowercased().contains(label.lowercased())
        }) else {
            return nil
        }
        return Classification(label: observation.identifier, confidence: observation.confidence)
    }
    
    /// 레이블 그룹별 합계 (카테고리 집계용)
    func groupedConfidence(
        for keywords: [String],
        in observations: [VNClassificationObservation]
    ) -> Float {
        observations
            .filter { observation in
                keywords.contains { keyword in
                    observation.identifier.lowercased().contains(keyword.lowercased())
                }
            }
            .reduce(0) { $0 + $1.confidence }
    }
}

// MARK: - 사용 예시
extension ResultParser {
    
    /// "강아지 종류" 인지 확인
    func isDog(observations: [VNClassificationObservation]) -> (isDog: Bool, confidence: Float) {
        let dogKeywords = ["dog", "retriever", "terrier", "spaniel", "poodle", "bulldog"]
        let confidence = groupedConfidence(for: dogKeywords, in: observations)
        return (confidence > 0.5, confidence)
    }
    
    /// "음식" 인지 확인
    func isFood(observations: [VNClassificationObservation]) -> (isFood: Bool, confidence: Float) {
        let foodKeywords = ["pizza", "burger", "sushi", "cake", "salad", "soup"]
        let confidence = groupedConfidence(for: foodKeywords, in: observations)
        return (confidence > 0.5, confidence)
    }
}
