import ARKit
import RealityKit

// 조명 추정 활성화
let configuration = ARWorldTrackingConfiguration()
configuration.isLightEstimationEnabled = true
arView.session.run(configuration)

// 조명 추정 값 사용
func session(_ session: ARSession, didUpdate frame: ARFrame) {
    guard let lightEstimate = frame.lightEstimate else { return }
    
    let ambientIntensity = lightEstimate.ambientIntensity // 루멘 단위
    let ambientColorTemperature = lightEstimate.ambientColorTemperature // 켈빈
    
    print("밝기: \(ambientIntensity), 색온도: \(ambientColorTemperature)K")
}
