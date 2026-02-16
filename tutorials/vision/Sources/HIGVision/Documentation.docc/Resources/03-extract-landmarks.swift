import Vision

extension FaceDetector {
    
    /// 랜드마크 데이터 추출
    func extractLandmarks(from observation: VNFaceObservation) -> FaceLandmarks? {
        guard let landmarks = observation.landmarks else {
            return nil
        }
        
        return FaceLandmarks(
            // 얼굴 윤곽
            faceContour: landmarks.faceContour?.normalizedPoints ?? [],
            
            // 눈
            leftEye: landmarks.leftEye?.normalizedPoints ?? [],
            rightEye: landmarks.rightEye?.normalizedPoints ?? [],
            leftPupil: landmarks.leftPupil?.normalizedPoints ?? [],
            rightPupil: landmarks.rightPupil?.normalizedPoints ?? [],
            
            // 눈썹
            leftEyebrow: landmarks.leftEyebrow?.normalizedPoints ?? [],
            rightEyebrow: landmarks.rightEyebrow?.normalizedPoints ?? [],
            
            // 코
            nose: landmarks.nose?.normalizedPoints ?? [],
            noseCrest: landmarks.noseCrest?.normalizedPoints ?? [],
            
            // 입
            innerLips: landmarks.innerLips?.normalizedPoints ?? [],
            outerLips: landmarks.outerLips?.normalizedPoints ?? [],
            
            // 기타
            medianLine: landmarks.medianLine?.normalizedPoints ?? []
        )
    }
}

struct FaceLandmarks {
    let faceContour: [CGPoint]
    let leftEye: [CGPoint]
    let rightEye: [CGPoint]
    let leftPupil: [CGPoint]
    let rightPupil: [CGPoint]
    let leftEyebrow: [CGPoint]
    let rightEyebrow: [CGPoint]
    let nose: [CGPoint]
    let noseCrest: [CGPoint]
    let innerLips: [CGPoint]
    let outerLips: [CGPoint]
    let medianLine: [CGPoint]
}
