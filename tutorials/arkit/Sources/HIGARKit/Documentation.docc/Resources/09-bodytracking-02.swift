import ARKit

class BodyTrackingDelegate: NSObject, ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
            
            let skeleton = bodyAnchor.skeleton
            
            // 사용 가능한 조인트 이름들
            let jointNames = skeleton.definition.jointNames
            print("추적 중인 조인트: \(jointNames.count)개")
            
            // 특정 조인트의 로컬 트랜스폼 가져오기
            if let headTransform = skeleton.localTransform(for: .head) {
                print("머리 위치 (로컬): \(headTransform.columns.3)")
            }
            
            if let leftHandTransform = skeleton.localTransform(for: .leftHand) {
                print("왼손 위치 (로컬): \(leftHandTransform.columns.3)")
            }
            
            // 월드 좌표로 변환
            let hipWorldPosition = bodyAnchor.transform.columns.3
            print("힙(루트) 월드 위치: \(hipWorldPosition)")
            
            // 모델 좌표로 변환 (루트 기준)
            if let rightFootTransform = skeleton.modelTransform(for: .rightFoot) {
                let worldTransform = bodyAnchor.transform * rightFootTransform
                print("오른발 월드 위치: \(worldTransform.columns.3)")
            }
        }
    }
}
