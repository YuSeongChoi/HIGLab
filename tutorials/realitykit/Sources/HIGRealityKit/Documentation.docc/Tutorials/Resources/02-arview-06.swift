import RealityKit
import ARKit

func configureEnvironmentTexturing(_ arView: ARView) {
    let config = ARWorldTrackingConfiguration()
    
    // 환경 텍스처링 (주변 환경 반사)
    
    // 자동: 기기 성능에 따라 결정
    config.environmentTexturing = .automatic
    
    // 수동: 직접 제어
    // config.environmentTexturing = .manual
    
    // 없음: 환경 텍스처링 비활성화
    // config.environmentTexturing = .none
    
    // 라이트 추정 활성화
    config.isLightEstimationEnabled = true
    
    arView.session.run(config)
    
    // 결과: 금속 재질의 객체가 주변 환경을 반사
}
