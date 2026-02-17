import RealityKit
import ARKit

// MARK: - 사람 오클루전 (People Occlusion)

func setupPeopleOcclusion(for arView: ARView) {
    
    let config = ARWorldTrackingConfiguration()
    
    // 사람 오클루전 지원 확인
    guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
        print("이 기기는 사람 오클루전을 지원하지 않습니다.")
        return
    }
    
    // 사람 오클루전 활성화
    config.frameSemantics.insert(.personSegmentationWithDepth)
    
    // 평면 감지와 함께 사용
    config.planeDetection = [.horizontal]
    config.environmentTexturing = .automatic
    
    arView.session.run(config)
}

// MARK: - 프레임 시멘틱 옵션

/*
 .personSegmentation
 - 사람 영역 감지 (2D 마스크만)
 - 간단한 사람 감지에 적합
 
 .personSegmentationWithDepth
 - 사람 영역 + 깊이 정보
 - 자연스러운 오클루전 가능
 
 .bodyDetection
 - 전신 3D 스켈레톤 추적
 - 모션 캡처, 아바타용
 */

// MARK: - 사람 오클루전 효과

/*
 사람 오클루전이 활성화되면:
 
 - 사람이 가상 객체 앞에 있으면 객체가 가려짐
 - 더 자연스러운 AR 경험 제공
 - A12 Bionic 이상 칩셋 필요
 */
