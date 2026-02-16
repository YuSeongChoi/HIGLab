import Vision
import UIKit

extension FaceDetector {
    
    /// 여러 이미지 중 가장 품질 좋은 얼굴 선택
    func selectBestQualityFace(from images: [UIImage]) async throws -> (image: UIImage, face: DetectedFace, quality: Float)? {
        var bestResult: (image: UIImage, face: DetectedFace, quality: Float)?
        
        for image in images {
            let results = try await detectFaceQuality(in: image)
            
            for (face, quality) in results {
                if bestResult == nil || quality > bestResult!.quality {
                    bestResult = (image, face, quality)
                }
            }
        }
        
        return bestResult
    }
    
    /// 품질 점수 해석
    func interpretQuality(_ quality: Float) -> String {
        switch quality {
        case 0.8...1.0:
            return "우수 - 선명한 얼굴"
        case 0.5..<0.8:
            return "보통 - 사용 가능"
        case 0.3..<0.5:
            return "낮음 - 흐릿하거나 가려짐"
        default:
            return "매우 낮음 - 재촬영 권장"
        }
    }
}
