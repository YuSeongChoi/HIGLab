import SwiftUI
import RealityKit
import ARKit

// MARK: - 기본 AR 앱 구조

/// 메인 앱 뷰
struct ContentView: View {
    var body: some View {
        ARViewContainer()
            .edgesIgnoringSafeArea(.all)
    }
}

/// ARView SwiftUI 래퍼
struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        // ARView 생성
        let arView = ARView(frame: .zero)
        
        // AR 세션 설정
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        
        arView.session.run(config)
        
        // 기본 박스 모델 추가
        let box = ModelEntity(
            mesh: .generateBox(size: 0.1),
            materials: [SimpleMaterial(color: .blue, isMetallic: true)]
        )
        
        // 앵커에 연결
        let anchor = AnchorEntity(plane: .horizontal)
        anchor.addChild(box)
        arView.scene.addAnchor(anchor)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // 뷰 업데이트 시 호출
    }
}

#Preview {
    ContentView()
}
