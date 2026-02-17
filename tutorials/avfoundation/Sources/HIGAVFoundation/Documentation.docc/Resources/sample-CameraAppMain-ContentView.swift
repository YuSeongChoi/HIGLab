import SwiftUI

// MARK: - 카메라 메인 뷰
// HIG: 카메라 인터페이스는 최소한의 UI로 촬영에 집중할 수 있어야 합니다.
// 중요한 컨트롤만 표시하고, 나머지는 필요할 때 접근할 수 있도록 합니다.

struct ContentView: View {
    
    // MARK: - State
    
    @StateObject private var cameraManager = CameraManager()
    @State private var showGallery = false
    @State private var showPermissionAlert = false
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경색 (카메라 로딩 전)
                Color.black.ignoresSafeArea()
                
                if cameraManager.isAuthorized {
                    // 카메라 프리뷰
                    cameraPreviewContent(geometry: geometry)
                } else {
                    // 권한 요청 화면
                    permissionRequestView
                }
            }
        }
        .task {
            await cameraManager.checkAuthorization()
            if cameraManager.isAuthorized {
                await cameraManager.setupSession()
                cameraManager.startSession()
            }
        }
        .onChange(of: cameraManager.isAuthorized) { _, authorized in
            if authorized {
                Task {
                    await cameraManager.setupSession()
                    cameraManager.startSession()
                }
            }
        }
        .sheet(isPresented: $showGallery) {
            MediaGalleryView(media: cameraManager.capturedMedia)
        }
        .alert("카메라 오류", isPresented: .constant(cameraManager.errorMessage != nil)) {
            Button("확인") {
                cameraManager.errorMessage = nil
            }
        } message: {
            Text(cameraManager.errorMessage ?? "")
        }
    }
    
    // MARK: - Camera Preview Content
    
    @ViewBuilder
    private func cameraPreviewContent(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // 상단 컨트롤 바
            topControlBar
            
            // 카메라 프리뷰 영역
            CameraPreviewView(session: cameraManager.session)
                .frame(height: geometry.size.width * 4 / 3)  // 4:3 비율
            
            Spacer()
            
            // 하단 컨트롤 영역
            bottomControlArea
        }
    }
    
    // MARK: - Top Control Bar
    
    private var topControlBar: some View {
        HStack {
            // 플래시 버튼
            Button {
                cameraManager.cycleFlashMode()
            } label: {
                Image(systemName: cameraManager.flashMode.symbol)
                    .font(.system(size: 20))
                    .foregroundColor(.yellow)
                    .frame(width: 44, height: 44)
            }
            .opacity(cameraManager.cameraPosition == .back ? 1 : 0.3)
            .disabled(cameraManager.cameraPosition == .front)
            
            Spacer()
            
            // 카메라 전환 버튼
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    cameraManager.switchCamera()
                }
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.3))
    }
    
    // MARK: - Bottom Control Area
    
    private var bottomControlArea: some View {
        HStack(alignment: .center) {
            // 갤러리 썸네일 버튼
            galleryButton
            
            Spacer()
            
            // 셔터 버튼
            CaptureButtonView {
                cameraManager.capturePhoto()
            }
            
            Spacer()
            
            // 빈 공간 (대칭 맞춤)
            Color.clear
                .frame(width: 60, height: 60)
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 20)
        .background(Color.black)
    }
    
    // MARK: - Gallery Button
    
    private var galleryButton: some View {
        Button {
            showGallery = true
        } label: {
            Group {
                if let lastMedia = cameraManager.capturedMedia.first {
                    Image(uiImage: lastMedia.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundColor(.white.opacity(0.5))
                        }
                }
            }
            .frame(width: 60, height: 60)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
            )
        }
    }
    
    // MARK: - Permission Request View
    
    private var permissionRequestView: some View {
        VStack(spacing: 24) {
            Image(systemName: "camera.fill")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.7))
            
            Text("카메라 접근 권한 필요")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("사진을 촬영하려면 카메라 접근 권한이 필요합니다.\n설정에서 권한을 허용해주세요.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("설정 열기") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.white)
            .foregroundColor(.black)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
