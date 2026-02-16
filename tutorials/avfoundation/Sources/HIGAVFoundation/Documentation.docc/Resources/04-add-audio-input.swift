import AVFoundation
import SwiftUI

@MainActor
class CameraManager: ObservableObject {
    let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    let movieOutput = AVCaptureMovieFileOutput()
    
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var audioDeviceInput: AVCaptureDeviceInput?
    
    // MARK: - Audio Input 추가
    
    func addAudioInput() {
        sessionQueue.async { [self] in
            // 마이크 장치 가져오기
            guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
                print("마이크를 찾을 수 없습니다.")
                return
            }
            
            do {
                let audioInput = try AVCaptureDeviceInput(device: audioDevice)
                
                captureSession.beginConfiguration()
                defer { captureSession.commitConfiguration() }
                
                if captureSession.canAddInput(audioInput) {
                    captureSession.addInput(audioInput)
                    audioDeviceInput = audioInput
                    print("✅ 오디오 입력 추가됨")
                } else {
                    print("오디오 입력을 추가할 수 없습니다.")
                }
            } catch {
                print("오디오 입력 생성 실패: \(error)")
            }
        }
    }
}
