import AVFoundation
import UIKit

/// PreviewLayer를 담는 UIView
class PreviewView: UIView {
    
    // 레이어 클래스를 AVCaptureVideoPreviewLayer로 지정
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    // 타입 캐스팅된 레이어 접근
    var previewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    // 세션 연결
    var session: AVCaptureSession? {
        get { previewLayer.session }
        set { previewLayer.session = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer()
    }
    
    private func setupLayer() {
        // 비디오 중력 설정
        previewLayer.videoGravity = .resizeAspectFill
    }
}
