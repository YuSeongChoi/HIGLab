import RealityKit

// 얼굴 앵커 (전면 카메라)
// =======================

func faceAnchor(_ arView: ARView) {
    // 전면 카메라 필요 (TrueDepth)
    // iPhone X 이상에서 지원
    
    // 얼굴 앵커 생성
    let faceAnchor = AnchorEntity(.face)
    
    // 얼굴에 부착할 콘텐츠 (AR 마스크, 필터 등)
    let mask = ModelEntity(
        mesh: .generateSphere(radius: 0.02),
        materials: [SimpleMaterial(color: .red, isMetallic: false)]
    )
    // 코 위치에 배치
    mask.position = SIMD3<Float>(0, 0, 0.05)
    
    faceAnchor.addChild(mask)
    arView.scene.addAnchor(faceAnchor)
}

// 참고: ARFaceTrackingConfiguration이 자동으로 설정됨
