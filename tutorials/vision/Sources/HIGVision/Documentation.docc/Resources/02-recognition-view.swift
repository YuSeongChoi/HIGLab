import SwiftUI
import PhotosUI

struct TextRecognitionView: View {
    @State private var selectedImage: UIImage?
    @State private var recognizedTexts: [RecognizedText] = []
    @State private var isProcessing = false
    @State private var showingImagePicker = false
    @State private var showingResults = false
    
    private let recognizer = TextRecognizer()
    
    var body: some View {
        VStack {
            // 이미지 표시 영역
            if let image = selectedImage {
                ImageWithOverlay(
                    image: image,
                    boundingBoxes: recognizedTexts.map(\.boundingBox)
                )
            } else {
                ContentUnavailableView(
                    "이미지 선택",
                    systemImage: "photo",
                    description: Text("텍스트를 인식할 이미지를 선택하세요")
                )
            }
            
            // 버튼
            HStack {
                Button("사진 선택") {
                    showingImagePicker = true
                }
                .buttonStyle(.bordered)
                
                Button("텍스트 인식") {
                    Task { await recognizeText() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedImage == nil || isProcessing)
            }
            .padding()
        }
        .navigationTitle("텍스트 인식")
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .sheet(isPresented: $showingResults) {
            TextResultsSheet(texts: recognizedTexts)
        }
    }
    
    private func recognizeText() async {
        guard let image = selectedImage else { return }
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            let observations = try await recognizer.recognizeText(in: image)
            recognizedTexts = recognizer.extractHighConfidenceText(from: observations)
            showingResults = true
        } catch {
            print("Error: \(error)")
        }
    }
}
