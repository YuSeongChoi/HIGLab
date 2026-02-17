import ARKit
import RealityKit

// 바디 트래킹 지원 확인
guard ARBodyTrackingConfiguration.isSupported else {
    fatalError("이 기기는 바디 트래킹을 지원하지 않습니다 (A12 Bionic 이상 필요)")
}

// 바디 트래킹 구성
let configuration = ARBodyTrackingConfiguration()
configuration.planeDetection = .horizontal
configuration.isAutoFocusEnabled = true

// 인물 세그멘테이션 (선택적)
if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentation) {
    configuration.frameSemantics.insert(.personSegmentation)
}

// 인물 가림 처리 (선택적)
if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
    configuration.frameSemantics.insert(.personSegmentationWithDepth)
}

arView.session.run(configuration)
print("바디 트래킹 시작")
