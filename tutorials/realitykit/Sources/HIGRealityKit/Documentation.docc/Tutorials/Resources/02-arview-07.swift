import RealityKit
import ARKit

func configurePeopleOcclusion(_ arView: ARView) {
    let config = ARWorldTrackingConfiguration()
    
    // 사람 오클루전 지원 여부 확인
    guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
        print("사람 오클루전이 지원되지 않는 기기입니다")
        return
    }
    
    // 사람 세그멘테이션 + 깊이 활성화
    config.frameSemantics.insert(.personSegmentationWithDepth)
    
    arView.session.run(config)
    
    // 결과: 가상 객체가 실제 사람 뒤에 자연스럽게 가려짐
}
