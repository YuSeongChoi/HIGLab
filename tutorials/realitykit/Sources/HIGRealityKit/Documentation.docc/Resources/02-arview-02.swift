import RealityKit
import ARKit

// MARK: - ARView 초기화 옵션

// 1. 기본 초기화 (자동 세션 구성)
let arView1 = ARView(frame: .zero)

// 2. 자동 구성 비활성화
let arView2 = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)

// 3. Non-AR 모드 (카메라 없이 3D만)
let arView3 = ARView(frame: .zero, cameraMode: .nonAR)

// MARK: - 카메라 모드

/*
 .ar            - AR 모드 (카메라 피드 + 3D)
 .nonAR         - 3D 뷰어 모드 (카메라 없음)
 .automatic     - 디바이스에 따라 자동 선택
 */

// MARK: - 프레임 설정

func setupARView() -> ARView {
    let frame = CGRect(x: 0, y: 0, width: 375, height: 812)
    let arView = ARView(
        frame: frame,
        cameraMode: .ar,
        automaticallyConfigureSession: true
    )
    return arView
}
