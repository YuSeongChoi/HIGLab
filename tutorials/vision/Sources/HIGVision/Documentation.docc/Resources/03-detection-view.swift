import SwiftUI

struct FaceDetectionView: View {
    @State private var selectedImage: UIImage?
    @State private var detectedFaces: [DetectedFace] = []
    @State private var isProcessing = false
    @State private var showingImagePicker = false
    
    private let detector = FaceDetector()
    
    var body: some View {
        VStack {
            if let image = selectedImage {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                    
                    FaceOverlayView(
                        faces: detectedFaces,
                        imageSize: image.size
                    )
                }
            } else {
                ContentUnavailableView(
                    "이미지 선택",
                    systemImage: "person.crop.rectangle",
                    description: Text("얼굴을 감지할 이미지를 선택하세요")
                )
            }
            
            HStack {
                Button("사진 선택") {
                    showingImagePicker = true
                }
                .buttonStyle(.bordered)
                
                Button("얼굴 감지") {
                    Task { await detectFaces() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedImage == nil || isProcessing)
            }
            .padding()
            
            if !detectedFaces.isEmpty {
                Text("감지된 얼굴: \(detectedFaces.count)명")
                    .font(.caption)
            }
        }
        .navigationTitle("얼굴 감지")
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }
    
    private func detectFaces() async {
        guard let image = selectedImage else { return }
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            detectedFaces = try await detector.detectAllFaces(in: image)
        } catch {
            print("Error: \(error)")
        }
    }
}
