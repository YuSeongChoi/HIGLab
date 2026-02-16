import Vision
import CoreGraphics

extension TextRecognizer {
    
    /// 바운딩 박스 추출 (UIKit 좌표로 변환)
    func extractBoundingBoxes(
        from observations: [VNRecognizedTextObservation],
        imageSize: CGSize
    ) -> [(text: String, frame: CGRect)] {
        return observations.compactMap { observation in
            guard let text = observation.topCandidates(1).first?.string else {
                return nil
            }
            
            // Vision 좌표 → UIKit 좌표 변환
            let frame = observation.boundingBox.toUIKit(in: imageSize)
            
            return (text, frame)
        }
    }
    
    /// 특정 영역 내 텍스트만 추출
    func extractTextInRegion(
        _ observations: [VNRecognizedTextObservation],
        region: CGRect // 정규화 좌표
    ) -> [String] {
        return observations.compactMap { observation in
            // 바운딩 박스가 지정 영역과 겹치는지 확인
            guard observation.boundingBox.intersects(region) else {
                return nil
            }
            return observation.topCandidates(1).first?.string
        }
    }
}
