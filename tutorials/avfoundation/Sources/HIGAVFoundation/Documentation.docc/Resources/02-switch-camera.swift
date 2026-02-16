import AVFoundation
import SwiftUI

@MainActor
class CameraManager: ObservableObject {
    let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    private var currentVideoDevice: AVCaptureDevice?
    private var videoDeviceInput: AVCaptureDeviceInput?
    
    @Published var isSessionRunning = false
    @Published var currentPosition: AVCaptureDevice.Position = .back
    
    // MARK: - Switch Camera
    
    func switchCamera() {
        sessionQueue.async { [self] in
            // 현재 입력이 없으면 리턴
            guard let currentInput = videoDeviceInput else { return }
            
            // 전환할 카메라 위치 결정
            let newPosition: AVCaptureDevice.Position = 
                currentPosition == .back ? .front : .back
            
            // 새 카메라 장치 찾기
            guard let newDevice = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: newPosition
            ) else { return }
            
            do {
                let newInput = try AVCaptureDeviceInput(device: newDevice)
                
                // 원자적 구성 변경
                captureSession.beginConfiguration()
                defer { captureSession.commitConfiguration() }
                
                // 기존 입력 제거
                captureSession.removeInput(currentInput)
                
                // 새 입력 추가
                if captureSession.canAddInput(newInput) {
                    captureSession.addInput(newInput)
                    videoDeviceInput = newInput
                    currentVideoDevice = newDevice
                    
                    Task { @MainActor in
                        currentPosition = newPosition
                    }
                } else {
                    // 실패 시 원래 입력 복원
                    captureSession.addInput(currentInput)
                }
            } catch {
                print("카메라 전환 실패: \(error)")
            }
        }
    }
}
