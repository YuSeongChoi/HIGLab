import SwiftUI
import AVFoundation

// MARK: - 카메라 프리뷰 뷰
// AVCaptureVideoPreviewLayer를 UIViewRepresentable로 래핑합니다.
// HIG: 카메라 프리뷰는 전체 화면을 활용하여 사용자가 촬영 결과를 예측할 수 있도록 합니다.

struct CameraPreviewView: UIViewRepresentable {
    
    /// AVCaptureSession (CameraManager에서 제공)
    let session: AVCaptureSession
    
    // MARK: - UIViewRepresentable
    
    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.session = session
        return view
    }
    
    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {
        // 세션이 변경되면 업데이트
        uiView.session = session
    }
}

// MARK: - 카메라 프리뷰 UIView

/// AVCaptureVideoPreviewLayer를 포함하는 UIView
class CameraPreviewUIView: UIView {
    
    // MARK: - Properties
    
    /// 프리뷰 레이어
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    /// 세션 설정 시 프리뷰 레이어 업데이트
    var session: AVCaptureSession? {
        didSet {
            updatePreviewLayer()
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 레이어 프레임을 뷰 크기에 맞춤
        previewLayer?.frame = bounds
    }
    
    // MARK: - Private Methods
    
    /// 뷰 초기 설정
    private func setupView() {
        backgroundColor = .black
    }
    
    /// 프리뷰 레이어 업데이트
    private func updatePreviewLayer() {
        // 기존 레이어 제거
        previewLayer?.removeFromSuperlayer()
        
        guard let session = session else { return }
        
        // 새 프리뷰 레이어 생성
        let newLayer = AVCaptureVideoPreviewLayer(session: session)
        newLayer.videoGravity = .resizeAspectFill  // 화면 채우기
        newLayer.frame = bounds
        
        // 비디오 방향 설정 (세로 모드)
        if let connection = newLayer.connection {
            if connection.isVideoRotationAngleSupported(90) {
                connection.videoRotationAngle = 90
            }
        }
        
        layer.addSublayer(newLayer)
        previewLayer = newLayer
    }
}

// MARK: - Preview

#Preview {
    CameraPreviewView(session: AVCaptureSession())
        .frame(height: 400)
        .background(Color.gray)
}
