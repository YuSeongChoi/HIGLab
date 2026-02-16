import RealityKit
import ARKit

// 앵커 지속성 (세션 간 유지)
// ==========================

func saveAnchor(_ arView: ARView, anchor: ARAnchor) {
    // 월드 맵 저장 (앵커 포함)
    arView.session.getCurrentWorldMap { worldMap, error in
        guard let worldMap = worldMap else {
            print("월드 맵 가져오기 실패: \(error?.localizedDescription ?? "")")
            return
        }
        
        // 파일로 저장
        do {
            let data = try NSKeyedArchiver.archivedData(
                withRootObject: worldMap,
                requiringSecureCoding: true
            )
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("worldmap.arexperience")
            try data.write(to: url)
            print("월드 맵 저장됨")
        } catch {
            print("저장 실패: \(error)")
        }
    }
}

func loadSavedAnchor(_ arView: ARView) {
    let url = FileManager.default.temporaryDirectory
        .appendingPathComponent("worldmap.arexperience")
    
    guard let data = try? Data(contentsOf: url),
          let worldMap = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data)
    else { return }
    
    let config = ARWorldTrackingConfiguration()
    config.initialWorldMap = worldMap
    arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
}
