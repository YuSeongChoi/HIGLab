import RealityKit
import ARKit

// MARK: - ARWorldTrackingConfiguration

func setupWorldTracking(for arView: ARView) {
    
    // 월드 트래킹 구성 생성
    let config = ARWorldTrackingConfiguration()
    
    // 6DoF (6 Degrees of Freedom) 트래킹
    // - 위치: X, Y, Z
    // - 회전: Pitch, Yaw, Roll
    
    // 세션 실행
    arView.session.run(config)
}

// MARK: - 다른 트래킹 구성들

/*
 ARWorldTrackingConfiguration
 - 가장 일반적인 구성
 - 6DoF 트래킹
 - 평면 감지, 이미지 트래킹 등 지원
 
 ARFaceTrackingConfiguration
 - 얼굴 인식 및 트래킹
 - 전면 카메라 사용 (TrueDepth)
 
 ARBodyTrackingConfiguration
 - 전신 트래킹
 - 모션 캡처, 아바타 등
 
 ARImageTrackingConfiguration
 - 이미지 마커 기반 트래킹
 - 월드 트래킹 없이 이미지만 추적
 
 ARGeoTrackingConfiguration
 - GPS/위치 기반 AR
 - 특정 장소에 고정된 콘텐츠
 */
