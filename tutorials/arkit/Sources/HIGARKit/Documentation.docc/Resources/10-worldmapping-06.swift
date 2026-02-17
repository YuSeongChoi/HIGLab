import ARKit
import RealityKit

class RelocalizationMonitor: NSObject, ARSessionDelegate {
    var arView: ARView!
    var onRelocalized: (() -> Void)?
    
    private var isRelocalized = false
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable:
            print("트래킹 불가")
            
        case .limited(let reason):
            switch reason {
            case .initializing:
                print("초기화 중...")
            case .relocalizing:
                print("재로컬라이제이션 중... 이전 위치를 찾고 있습니다")
                showRelocalizationGuide()
            case .excessiveMotion:
                print("움직임이 너무 빠릅니다")
            case .insufficientFeatures:
                print("특징점 부족 - 더 밝은 곳으로 이동하세요")
            @unknown default:
                break
            }
            
        case .normal:
            if !isRelocalized {
                isRelocalized = true
                print("재로컬라이제이션 성공! ✓")
                hideRelocalizationGuide()
                onRelocalized?()
            }
        }
    }
    
    private func showRelocalizationGuide() {
        // 이전에 저장한 위치로 돌아가라는 안내 표시
        print("💡 월드 맵을 저장했던 위치로 이동하세요")
    }
    
    private func hideRelocalizationGuide() {
        print("✅ 이전 AR 세션이 복원되었습니다")
    }
}
