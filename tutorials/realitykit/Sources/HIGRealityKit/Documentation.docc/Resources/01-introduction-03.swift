import RealityKit

// MARK: - 플랫폼 지원
// RealityKit은 여러 Apple 플랫폼에서 사용할 수 있습니다.

#if os(iOS)
import ARKit

// iOS에서는 ARView 사용
// 카메라 기반 AR 경험
struct iOSARSetup {
    func createARView() -> ARView {
        let arView = ARView(frame: .zero)
        
        // AR 세션 설정
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        arView.session.run(config)
        
        return arView
    }
}
#endif

#if os(macOS)
// macOS에서는 ARView 없이 사용 가능
// 3D 뷰어나 에디터 용도
struct macOSSetup {
    func createScene() -> Scene {
        let scene = Scene()
        // 3D 콘텐츠 추가
        return scene
    }
}
#endif

#if os(visionOS)
// visionOS에서는 RealityView 사용
// 몰입형 공간 경험
import SwiftUI

struct visionOSView: View {
    var body: some View {
        RealityView { content in
            // 3D 콘텐츠 추가
            let box = ModelEntity(
                mesh: .generateBox(size: 0.3),
                materials: [SimpleMaterial(color: .blue, isMetallic: true)]
            )
            content.add(box)
        }
    }
}
#endif
