import SwiftUI
import RealityKit

// SwiftUI에서 ARView 사용하기
struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        // ARView 인스턴스 생성
        let arView = ARView(frame: .zero)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // SwiftUI 상태 변경 시 호출
    }
}

// ContentView에서 사용
struct ContentView: View {
    var body: some View {
        ARViewContainer()
            .edgesIgnoringSafeArea(.all)
    }
}
