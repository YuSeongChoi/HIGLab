import Vision
import CoreML

/// VNCoreMLRequest로 분류 요청 생성
struct ClassificationRequestSetup {
    
    /// 기본 분류 요청 생성
    func createRequest(model: VNCoreMLModel) -> VNCoreMLRequest {
        let request = VNCoreMLRequest(model: model) { request, error in
            // 결과 처리 핸들러
            if let error = error {
                print("분류 에러: \(error.localizedDescription)")
                return
            }
            
            guard let results = request.results as? [VNClassificationObservation] else {
                print("결과 타입 오류")
                return
            }
            
            // 상위 5개 결과 출력
            for result in results.prefix(5) {
                let confidence = result.confidence * 100
                print("\(result.identifier): \(String(format: "%.2f", confidence))%")
            }
        }
        
        // 이미지 크롭 옵션 설정
        request.imageCropAndScaleOption = .centerCrop
        
        return request
    }
    
    /// 이미지 크롭 옵션들
    ///
    /// - .centerCrop: 중앙 기준 정사각형 크롭 (권장)
    /// - .scaleFit: 비율 유지하며 맞춤 (여백 발생)
    /// - .scaleFill: 비율 유지하며 채움 (일부 잘림)
    func cropOptions() -> [VNImageCropAndScaleOption] {
        return [.centerCrop, .scaleFit, .scaleFill]
    }
}

// MARK: - Async/Await 패턴 (iOS 15+)
extension ClassificationRequestSetup {
    
    /// async/await로 분류 요청 실행
    func classifyAsync(image: CGImage, model: VNCoreMLModel) async throws -> [VNClassificationObservation] {
        let request = VNCoreMLRequest(model: model)
        request.imageCropAndScaleOption = .centerCrop
        
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        
        // 백그라운드에서 실행
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                    
                    guard let results = request.results as? [VNClassificationObservation] else {
                        continuation.resume(throwing: ClassificationError.invalidResults)
                        return
                    }
                    
                    continuation.resume(returning: results)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

enum ClassificationError: Error {
    case invalidResults
    case modelNotReady
}
