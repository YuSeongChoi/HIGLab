import AVFoundation
import SwiftUI

@MainActor
class CameraManager: ObservableObject {
    let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    // 사진 촬영용
    let photoOutput = AVCapturePhotoOutput()
    
    // 비디오 녹화용
    let movieOutput = AVCaptureMovieFileOutput()
    
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var audioDeviceInput: AVCaptureDeviceInput?
    
    @Published var isSessionRunning = false
    @Published var isRecording = false
}
