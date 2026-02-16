import Vision
import UIKit

func analyzeImage(_ image: CGImage) throws -> [VNObservation] {
    // 1️⃣ Request 생성
    let request = VNRecognizeTextRequest()
    
    // 2️⃣ Handler에 이미지 전달
    let handler = VNImageRequestHandler(
        cgImage: image,
        options: [:]
    )
    
    // 3️⃣ Request 실행
    try handler.perform([request])
    
    // 4️⃣ Observation 결과 반환
    return request.results ?? []
}
