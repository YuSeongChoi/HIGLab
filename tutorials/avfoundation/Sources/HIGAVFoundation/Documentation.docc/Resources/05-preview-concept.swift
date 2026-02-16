import AVFoundation
import UIKit

// AVCaptureVideoPreviewLayer 개념
//
// AVCaptureVideoPreviewLayer는 CALayer의 서브클래스입니다.
// 캡처 세션의 실시간 비디오 스트림을 화면에 표시합니다.
//
// 특징:
// - 하드웨어 가속 렌더링
// - 낮은 지연 시간
// - 자동 회전 지원
// - 다양한 비디오 중력 옵션

class PreviewLayerExample {
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    func setupPreviewLayer(in view: UIView) {
        // PreviewLayer 생성
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        // 비디오 중력 설정 (화면 채우기)
        previewLayer.videoGravity = .resizeAspectFill
        
        // 뷰 크기에 맞게 레이어 크기 설정
        previewLayer.frame = view.bounds
        
        // 뷰의 레이어에 추가
        view.layer.addSublayer(previewLayer)
        
        self.previewLayer = previewLayer
    }
}
