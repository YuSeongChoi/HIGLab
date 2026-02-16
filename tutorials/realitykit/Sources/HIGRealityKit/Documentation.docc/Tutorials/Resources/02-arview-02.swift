import RealityKit

// ARView 초기화 옵션
// ==================

// 기본 초기화
let arView1 = ARView(frame: .zero)

// 프레임 지정 초기화
let arView2 = ARView(frame: CGRect(x: 0, y: 0, width: 400, height: 600))

// 옵션과 함께 초기화
let arView3 = ARView(
    frame: .zero,
    cameraMode: .ar,           // AR 또는 nonAR
    automaticallyConfigureSession: true  // 자동 세션 구성
)

// non-AR 모드 (카메라 피드 없이 3D만)
let arView4 = ARView(
    frame: .zero,
    cameraMode: .nonAR,
    automaticallyConfigureSession: false
)
