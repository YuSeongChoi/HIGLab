import ARKit
import RealityKit

// 월드 맵핑 상태 모니터링
class WorldMappingMonitor: NSObject, ARSessionDelegate {
    var arView: ARView!
    var statusLabel: UILabel?
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // 월드 맵핑 상태 확인
        let mappingStatus = frame.worldMappingStatus
        
        switch mappingStatus {
        case .notAvailable:
            statusLabel?.text = "월드 맵 사용 불가"
            statusLabel?.textColor = .red
            
        case .limited:
            statusLabel?.text = "월드 맵 제한적 - 더 둘러보세요"
            statusLabel?.textColor = .orange
            
        case .extending:
            statusLabel?.text = "월드 맵 확장 중"
            statusLabel?.textColor = .yellow
            
        case .mapped:
            statusLabel?.text = "월드 맵 완료 ✓ 저장 가능"
            statusLabel?.textColor = .green
            
        @unknown default:
            break
        }
    }
    
    var canSaveWorldMap: Bool {
        guard let frame = arView.session.currentFrame else { return false }
        return frame.worldMappingStatus == .mapped || frame.worldMappingStatus == .extending
    }
}
