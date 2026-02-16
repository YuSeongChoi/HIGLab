import Vision

extension TextRecognizer {
    
    /// 모든 Observation에서 텍스트를 추출하고 합침
    func extractAllText(from observations: [VNRecognizedTextObservation]) -> String {
        let texts = observations.compactMap { observation in
            observation.topCandidates(1).first?.string
        }
        
        // 줄바꿈으로 연결
        return texts.joined(separator: "\n")
    }
    
    /// 위치 순서대로 정렬 후 추출 (위에서 아래, 왼쪽에서 오른쪽)
    func extractSortedText(from observations: [VNRecognizedTextObservation]) -> String {
        let sortedObservations = observations.sorted { a, b in
            // Y 좌표로 먼저 정렬 (위에서 아래)
            if abs(a.boundingBox.midY - b.boundingBox.midY) > 0.02 {
                return a.boundingBox.midY > b.boundingBox.midY
            }
            // 같은 줄이면 X 좌표로 정렬 (왼쪽에서 오른쪽)
            return a.boundingBox.minX < b.boundingBox.minX
        }
        
        return sortedObservations.compactMap { observation in
            observation.topCandidates(1).first?.string
        }.joined(separator: " ")
    }
}
