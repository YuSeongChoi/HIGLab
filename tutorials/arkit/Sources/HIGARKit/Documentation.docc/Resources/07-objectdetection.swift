import ARKit
import RealityKit

// 객체 스캐닝 지원 확인
guard ARObjectScanningConfiguration.isSupported else {
    fatalError("이 기기는 객체 스캐닝을 지원하지 않습니다")
}

// 스캐닝 구성 설정
let scanningConfig = ARObjectScanningConfiguration()
scanningConfig.planeDetection = .horizontal

// 스캐닝 영역 정의 (바운딩 박스)
let boundingBox = CGSize(width: 0.3, height: 0.3) // 30cm x 30cm
print("스캔할 객체를 바운딩 박스 안에 위치시키세요")

// 스캐닝 세션 시작
arView.session.run(scanningConfig)
