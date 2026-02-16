import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var cameraManager = CameraManager()
    
    var body: some View {
        ZStack {
            CameraPreviewView(session: cameraManager.captureSession)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                HStack(spacing: 60) {
                    // 갤러리 버튼
                    thumbnailButton
                    
                    // 셔터 버튼
                    shutterButton
                    
                    // 카메라 전환 버튼
                    switchCameraButton
                }
                .padding(.bottom, 30)
            }
        }
        .task {
            await cameraManager.requestCameraPermission()
            cameraManager.configureSession()
            cameraManager.startSession()
        }
    }
    
    // MARK: - Shutter Button
    
    private var shutterButton: some View {
        Button(action: {
            cameraManager.capturePhoto()
        }) {
            ZStack {
                Circle()
                    .stroke(Color.white, lineWidth: 4)
                    .frame(width: 70, height: 70)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 60, height: 60)
                    .scaleEffect(cameraManager.isCapturing ? 0.9 : 1.0)
            }
        }
        .disabled(cameraManager.isCapturing)
        .animation(.easeInOut(duration: 0.1), value: cameraManager.isCapturing)
    }
    
    private var thumbnailButton: some View {
        Button(action: {}) {
            if let image = cameraManager.capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
            }
        }
    }
    
    private var switchCameraButton: some View {
        Button(action: { cameraManager.switchCamera() }) {
            Image(systemName: "arrow.triangle.2.circlepath.camera")
                .font(.title)
                .foregroundColor(.white)
        }
        .frame(width: 50, height: 50)
    }
}
