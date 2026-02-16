import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    let onTap: (CGPoint) -> Void
    
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.session = session
        
        // 탭 제스처 추가
        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        view.addGestureRecognizer(tapGesture)
        
        return view
    }
    
    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.session = session
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject {
        let parent: CameraPreviewView
        
        init(_ parent: CameraPreviewView) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let view = gesture.view as? PreviewView else { return }
            
            // 탭 위치 (뷰 좌표계)
            let tapPoint = gesture.location(in: view)
            
            // 카메라 좌표계로 변환
            let devicePoint = view.previewLayer.captureDevicePointConverted(
                fromLayerPoint: tapPoint
            )
            
            parent.onTap(devicePoint)
        }
    }
}

class PreviewView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    var session: AVCaptureSession? {
        get { previewLayer.session }
        set { previewLayer.session = newValue }
    }
}
