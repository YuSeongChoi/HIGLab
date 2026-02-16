import RealityKit
import ARKit

func configureWorldTracking(_ arView: ARView) {
    // ARWorldTrackingConfiguration 생성
    let config = ARWorldTrackingConfiguration()
    
    // 월드 트래킹 옵션 설정
    config.worldAlignment = .gravity  // 중력 방향 기준
    
    // 세션 실행
    arView.session.run(config)
}

// 다른 구성 옵션들:
// - ARFaceTrackingConfiguration: 얼굴 트래킹 (전면 카메라)
// - ARBodyTrackingConfiguration: 신체 트래킹
// - ARImageTrackingConfiguration: 이미지 인식만
// - ARGeoTrackingConfiguration: 지리적 위치 기반
