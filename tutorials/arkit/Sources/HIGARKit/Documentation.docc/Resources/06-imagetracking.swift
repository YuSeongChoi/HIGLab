import ARKit
import RealityKit

// Assets에서 Reference Images 로드
guard let referenceImages = ARReferenceImage.referenceImages(
    inGroupNamed: "AR Resources",
    bundle: nil
) else {
    fatalError("Reference images를 찾을 수 없습니다")
}

// 이미지 트래킹 구성
let configuration = ARImageTrackingConfiguration()
configuration.trackingImages = referenceImages
configuration.maximumNumberOfTrackedImages = 4 // 동시 추적 이미지 수

// 또는 월드 트래킹과 함께 사용
let worldConfig = ARWorldTrackingConfiguration()
worldConfig.detectionImages = referenceImages
worldConfig.maximumNumberOfTrackedImages = 2

arView.session.run(configuration)
