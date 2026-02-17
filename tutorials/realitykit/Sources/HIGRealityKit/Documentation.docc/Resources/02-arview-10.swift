import SwiftUI
import RealityKit
import ARKit

// MARK: - 완성된 ARView 설정

struct CompleteARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        // 1. ARView 생성
        let arView = ARView(
            frame: .zero,
            cameraMode: .ar,
            automaticallyConfigureSession: false
        )
        
        // 2. 환경 설정
        configureEnvironment(arView)
        
        // 3. AR 세션 설정
        configureSession(arView)
        
        // 4. 디버그 옵션 (개발 중만)
        #if DEBUG
        arView.debugOptions = [.showFeaturePoints, .showAnchorGeometry]
        #endif
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) { }
    
    // MARK: - 환경 설정
    
    private func configureEnvironment(_ arView: ARView) {
        // 배경
        arView.environment.background = .cameraFeed()
        
        // 조명
        arView.environment.lighting.intensityExponent = 1.0
        
        // 렌더링 옵션
        arView.renderOptions = [
            .disableMotionBlur,
            .disableDepthOfField
        ]
    }
    
    // MARK: - 세션 설정
    
    private func configureSession(_ arView: ARView) {
        let config = ARWorldTrackingConfiguration()
        
        // 평면 감지
        config.planeDetection = [.horizontal, .vertical]
        
        // 환경 텍스처링
        config.environmentTexturing = .automatic
        
        // 사람 오클루전 (지원 시)
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            config.frameSemantics.insert(.personSegmentationWithDepth)
        }
        
        // 세션 시작
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
}

// MARK: - 사용

struct ContentView: View {
    var body: some View {
        CompleteARViewContainer()
            .edgesIgnoringSafeArea(.all)
    }
}
