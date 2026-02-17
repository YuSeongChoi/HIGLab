import SwiftUI
import RealityKit
import ARKit

// MARK: - ARView SwiftUI 래퍼

/// SwiftUI에서 ARView를 사용하기 위한 UIViewRepresentable
struct ARViewContainer: UIViewRepresentable {
    
    /// ARView 생성
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // 기본 AR 세션 시작
        let config = ARWorldTrackingConfiguration()
        arView.session.run(config)
        
        return arView
    }
    
    /// ARView 업데이트
    func updateUIView(_ uiView: ARView, context: Context) {
        // 필요 시 업데이트 로직
    }
}

// MARK: - 사용 예시

struct ContentView: View {
    var body: some View {
        ARViewContainer()
            .edgesIgnoringSafeArea(.all)
    }
}
