import RealityKit

// 에러 처리
// =========

enum ModelLoadingError: Error {
    case fileNotFound
    case invalidFormat
    case loadingFailed(underlying: Error)
}

func loadModelWithErrorHandling(_ arView: ARView) {
    do {
        let entity = try Entity.load(named: "toy_robot")
        
        let anchor = AnchorEntity(plane: .horizontal)
        anchor.addChild(entity)
        arView.scene.addAnchor(anchor)
        
    } catch let error as NSError {
        // 에러 유형 분석
        switch error.code {
        case NSFileReadNoSuchFileError:
            print("파일을 찾을 수 없습니다")
        case NSFileReadCorruptFileError:
            print("파일이 손상되었습니다")
        default:
            print("알 수 없는 에러: \(error.localizedDescription)")
        }
    }
}
