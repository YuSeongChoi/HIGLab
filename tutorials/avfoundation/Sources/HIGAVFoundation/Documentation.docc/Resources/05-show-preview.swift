import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var cameraManager = CameraManager()
    
    var body: some View {
        ZStack {
            // 카메라 프리뷰
            CameraPreviewView(session: cameraManager.captureSession)
                .ignoresSafeArea()
            
            // 컨트롤 오버레이
            VStack {
                // 상단 바
                HStack {
                    Spacer()
                    
                    // 플래시 토글
                    Button(action: {}) {
                        Image(systemName: "bolt.slash.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .padding()
                }
                
                Spacer()
                
                // 하단 컨트롤
                bottomControls
            }
        }
        .task {
            await cameraManager.requestCameraPermission()
            cameraManager.configureSession()
            cameraManager.startSession()
        }
    }
    
    private var bottomControls: some View {
        HStack(spacing: 60) {
            // 갤러리
            thumbnailButton
            
            // 셔터
            shutterButton
            
            // 카메라 전환
            switchButton
        }
        .padding(.bottom, 30)
    }
    
    private var thumbnailButton: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.3))
            .frame(width: 50, height: 50)
    }
    
    private var shutterButton: some View {
        Button(action: { cameraManager.capturePhoto() }) {
            ZStack {
                Circle().stroke(Color.white, lineWidth: 4)
                Circle().fill(Color.white).padding(6)
            }
            .frame(width: 70, height: 70)
        }
    }
    
    private var switchButton: some View {
        Button(action: { cameraManager.switchCamera() }) {
            Image(systemName: "arrow.triangle.2.circlepath.camera")
                .font(.title)
                .foregroundColor(.white)
        }
        .frame(width: 50, height: 50)
    }
}
