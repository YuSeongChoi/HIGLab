import SwiftUI
import PhotosUI

/// 이미지 분류 앱의 메인 화면
struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var classificationResult: String = "이미지를 선택하세요"
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 이미지 표시 영역
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 300)
                    
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 280)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        VStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 60))
                                .foregroundStyle(.gray)
                            Text("이미지를 선택하세요")
                                .foregroundStyle(.gray)
                        }
                    }
                }
                .padding(.horizontal)
                
                // 분류 결과
                Text(classificationResult)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
                
                // 이미지 선택 버튼
                Button(action: { showingImagePicker = true }) {
                    Label("사진 선택", systemImage: "photo.fill")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            .navigationTitle("이미지 분류")
            .sheet(isPresented: $showingImagePicker) {
                // ImagePicker는 다음 챕터에서 구현
                Text("ImagePicker")
            }
        }
    }
}

#Preview {
    ContentView()
}
