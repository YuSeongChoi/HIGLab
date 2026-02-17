import ARKit
import RealityKit

// Assets에서 참조 객체 로드
guard let referenceObjects = ARReferenceObject.referenceObjects(
    inGroupNamed: "AR Objects",
    bundle: nil
) else {
    fatalError("참조 객체를 찾을 수 없습니다")
}

// 또는 파일에서 직접 로드
let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let objectURL = documentsURL.appendingPathComponent("my_object.arobject")
if let loadedObject = try? ARReferenceObject(archiveURL: objectURL) {
    print("객체 로드됨: \(loadedObject.name ?? "unnamed")")
}

// 월드 트래킹에서 객체 감지 설정
let configuration = ARWorldTrackingConfiguration()
configuration.detectionObjects = referenceObjects
configuration.planeDetection = [.horizontal, .vertical]

arView.session.run(configuration)
