import RealityKit
import ARKit

// MARK: - 렌더링 통계

func displayStatistics(_ arView: ARView) {
    
    // 통계 표시 활성화
    #if DEBUG
    arView.debugOptions.insert(.showStatistics)
    #endif
    
    /*
     통계 정보 포함:
     - FPS (Frames Per Second)
     - 삼각형 수 (Triangles)
     - 드로우 콜 수 (Draw Calls)
     - 메모리 사용량
     - 씬 복잡도
     */
}

// MARK: - 성능 모니터링

func monitorPerformance(_ arView: ARView) {
    
    // 현재 프레임 정보 접근
    if let frame = arView.session.currentFrame {
        // 추적 상태
        let trackingState = frame.camera.trackingState
        
        switch trackingState {
        case .normal:
            print("✅ 정상 추적")
        case .limited(let reason):
            print("⚠️ 제한된 추적: \(reason)")
        case .notAvailable:
            print("❌ 추적 불가")
        }
        
        // 앵커 정보
        print("감지된 앵커: \(frame.anchors.count)")
    }
}
