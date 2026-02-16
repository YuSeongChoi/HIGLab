import Vision

// VNRecognizedTextObservation 구조
// - boundingBox: 텍스트 영역 (정규화 좌표)
// - topCandidates(_:): 인식 후보 목록

func processObservations(_ observations: [VNRecognizedTextObservation]) {
    for observation in observations {
        // 바운딩 박스 (정규화 좌표: 0.0 ~ 1.0)
        let boundingBox = observation.boundingBox
        print("위치: \(boundingBox)")
        
        // 상위 1개 인식 후보
        guard let topCandidate = observation.topCandidates(1).first else {
            continue
        }
        
        // 인식된 텍스트
        let recognizedText = topCandidate.string
        print("텍스트: \(recognizedText)")
        
        // 신뢰도 (0.0 ~ 1.0)
        let confidence = topCandidate.confidence
        print("신뢰도: \(confidence)")
    }
}
