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
                Spacer()
                
                // 하단 컨트롤 바
                HStack(spacing: 60) {
                    // 갤러리 버튼
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
                    
                    // 셔터 버튼 (다음 단계에서 구현)
                    Circle()
                        .stroke(Color.white, lineWidth: 4)
                        .frame(width: 70, height: 70)
                    
                    // 카메라 전환 버튼
                    Button(action: { cameraManager.switchCamera() }) {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .frame(width: 50, height: 50)
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
}
