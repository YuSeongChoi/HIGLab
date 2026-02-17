import ARKit

// BlendShapes로 표정 데이터 읽기
func processBlendShapes(from faceAnchor: ARFaceAnchor) {
    let blendShapes = faceAnchor.blendShapes
    
    // 눈 깜빡임
    let leftEyeBlink = blendShapes[.eyeBlinkLeft]?.floatValue ?? 0
    let rightEyeBlink = blendShapes[.eyeBlinkRight]?.floatValue ?? 0
    
    // 입 모양
    let mouthOpen = blendShapes[.jawOpen]?.floatValue ?? 0
    let mouthSmileLeft = blendShapes[.mouthSmileLeft]?.floatValue ?? 0
    let mouthSmileRight = blendShapes[.mouthSmileRight]?.floatValue ?? 0
    
    // 눈썹
    let browInnerUp = blendShapes[.browInnerUp]?.floatValue ?? 0
    let browDownLeft = blendShapes[.browDownLeft]?.floatValue ?? 0
    
    // 혀 감지 (A14 이상)
    let tongueOut = blendShapes[.tongueOut]?.floatValue ?? 0
    
    // 표정 분석
    let isSmiling = (mouthSmileLeft + mouthSmileRight) / 2 > 0.5
    let isBlinking = (leftEyeBlink + rightEyeBlink) / 2 > 0.5
    let isSurprised = browInnerUp > 0.5 && mouthOpen > 0.3
    
    print("웃음: \(isSmiling), 깜빡임: \(isBlinking), 놀람: \(isSurprised)")
}
