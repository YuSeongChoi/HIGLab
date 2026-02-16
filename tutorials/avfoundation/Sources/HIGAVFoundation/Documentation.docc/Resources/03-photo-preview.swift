import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var showPhotoPreview = false
    
    var body: some View {
        ZStack {
            CameraPreviewView(session: cameraManager.captureSession)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                HStack(spacing: 60) {
                    thumbnailButton
                    shutterButton
                    switchCameraButton
                }
                .padding(.bottom, 30)
            }
        }
        // 촬영된 이미지 변경 감지
        .onChange(of: cameraManager.capturedImage) { oldImage, newImage in
            if newImage != nil {
                showPhotoPreview = true
            }
        }
        // 미리보기 시트
        .sheet(isPresented: $showPhotoPreview) {
            PhotoPreviewView(image: cameraManager.capturedImage)
        }
        .task {
            await cameraManager.requestCameraPermission()
            cameraManager.configureSession()
            cameraManager.startSession()
        }
    }
    
    // ... (버튼들 구현은 이전과 동일)
}

// MARK: - Photo Preview View

struct PhotoPreviewView: View {
    let image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Text("이미지를 불러올 수 없습니다.")
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("완료") {
                    dismiss()
                }
            }
        }
    }
}
