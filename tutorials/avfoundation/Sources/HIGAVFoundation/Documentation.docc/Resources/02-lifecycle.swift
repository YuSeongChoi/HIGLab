import AVFoundation
import SwiftUI
import Combine

@MainActor
class CameraManager: ObservableObject {
    let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    private var currentVideoDevice: AVCaptureDevice?
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isSessionRunning = false
    
    init() {
        setupLifecycleObservers()
    }
    
    // MARK: - Lifecycle Observers
    
    private func setupLifecycleObservers() {
        // 앱이 백그라운드로 전환될 때
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.stopSession()
            }
            .store(in: &cancellables)
        
        // 앱이 포그라운드로 돌아올 때
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.startSession()
            }
            .store(in: &cancellables)
    }
    
    func startSession() {
        sessionQueue.async { [self] in
            if !captureSession.isRunning {
                captureSession.startRunning()
                Task { @MainActor in
                    isSessionRunning = true
                }
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async { [self] in
            if captureSession.isRunning {
                captureSession.stopRunning()
                Task { @MainActor in
                    isSessionRunning = false
                }
            }
        }
    }
}
