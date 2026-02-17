import RealityKit
import ARKit

// MARK: - ARView 주요 프로퍼티

func configureARView(_ arView: ARView) {
    
    // 1. scene - RealityKit Scene (앵커와 엔티티 관리)
    let scene = arView.scene
    print("앵커 수: \(scene.anchors.count)")
    
    // 2. session - ARKit 세션
    let session = arView.session
    print("세션 상태: \(session.currentFrame != nil)")
    
    // 3. cameraMode - 카메라 모드
    // arView.cameraMode = .ar
    
    // 4. renderOptions - 렌더링 옵션
    arView.renderOptions = [
        .disableMotionBlur,        // 모션 블러 비활성화
        .disableDepthOfField,      // 피사계 심도 비활성화
        .disableHDR,               // HDR 비활성화
        .disableGroundingShadows   // 바닥 그림자 비활성화
    ]
    
    // 5. environment - 환경 설정
    arView.environment.background = .cameraFeed()  // 카메라 배경
    arView.environment.lighting.intensityExponent = 1.0
    
    // 6. cameraTransform - 카메라 위치/방향
    let cameraTransform = arView.cameraTransform
    print("카메라 위치: \(cameraTransform.translation)")
}
