import RealityKit

func configureARView(_ arView: ARView) {
    // scene: RealityKit 씬에 접근
    let scene = arView.scene
    
    // 앵커 추가
    let anchor = AnchorEntity(plane: .horizontal)
    scene.addAnchor(anchor)
    
    // cameraMode 확인
    print("Camera Mode: \(arView.cameraMode)")
    
    // renderOptions 설정
    arView.renderOptions = [
        .disableMotionBlur,
        .disableDepthOfField,
        .disableCameraGrain
    ]
    
    // environment 설정 (조명, 배경)
    arView.environment.lighting.intensityExponent = 1.0
}
