import Vision

extension TextRecognizer {
    
    /// 실시간 프리뷰용 빠른 텍스트 인식
    /// - Note: Chapter 9에서 카메라와 연동할 때 사용
    func createRealtimeTextRequest() -> VNRecognizeTextRequest {
        let request = VNRecognizeTextRequest()
        
        // 실시간 처리를 위한 설정
        request.recognitionLevel = .fast  // 속도 우선
        request.usesLanguageCorrection = false  // 언어 교정 비활성화 (속도 향상)
        request.recognitionLanguages = ["ko-KR", "en-US"]
        
        return request
    }
    
    /// 고품질 최종 스캔용 텍스트 인식
    func createAccurateTextRequest() -> VNRecognizeTextRequest {
        let request = VNRecognizeTextRequest()
        
        // 정확도 우선 설정
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true  // 언어 교정 활성화
        request.recognitionLanguages = ["ko-KR", "en-US", "ja-JP"]
        request.automaticallyDetectsLanguage = true
        
        return request
    }
}
