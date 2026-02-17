import ARKit
import RealityKit

// 얼굴 트래킹 지원 확인
guard ARFaceTrackingConfiguration.isSupported else {
    fatalError("이 기기는 얼굴 트래킹을 지원하지 않습니다 (TrueDepth 카메라 필요)")
}

// 얼굴 트래킹 구성
let configuration = ARFaceTrackingConfiguration()
configuration.isLightEstimationEnabled = true
configuration.maximumNumberOfTrackedFaces = ARFaceTrackingConfiguration.supportedNumberOfTrackedFaces

print("최대 \(configuration.maximumNumberOfTrackedFaces)명의 얼굴을 동시 추적 가능")

// 전면 카메라로 세션 시작
arView.session.run(configuration)
