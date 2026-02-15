import ARKit
import RealityKit

class PlaneDetectionDelegate: NSObject, ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let planeAnchor = anchor as? ARPlaneAnchor else { continue }
            
            // 평면 유형 확인
            switch planeAnchor.classification {
            case .floor:
                print("바닥 감지")
            case .wall:
                print("벽 감지")
            case .table:
                print("테이블 감지")
            default:
                break
            }
        }
    }
}
