import RealityKit
import UIKit

extension ARView {
    func setupGestures() {
        // 탭 제스처 - 모델 선택/배치
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: self)
        
        // 레이캐스트로 평면 찾기
        guard let result = raycast(from: location, allowing: .existingPlaneGeometry, alignment: .horizontal).first else { return }
        
        // 해당 위치에 모델 배치
        Task {
            await loadAndPlaceModel(in: self, at: result.worldTransform.position)
        }
    }
}

extension simd_float4x4 {
    var position: SIMD3<Float> {
        SIMD3(columns.3.x, columns.3.y, columns.3.z)
    }
}
