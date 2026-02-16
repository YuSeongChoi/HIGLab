import SwiftUI
import RealityKit
import ARKit

struct OptimizedARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        // ARView 생성
        let arView = ARView(frame: .zero)
        
        // AR 세션 구성
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        config.isLightEstimationEnabled = true
        
        // 사람 오클루전 (지원 시)
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            config.frameSemantics.insert(.personSegmentationWithDepth)
        }
        
        // 세션 시작
        arView.session.run(config)
        
        // 렌더 옵션
        arView.renderOptions = [.disableCameraGrain]
        
        // 디버그 (개발 중에만)
        #if DEBUG
        arView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        #endif
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}
