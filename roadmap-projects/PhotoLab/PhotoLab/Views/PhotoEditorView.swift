import SwiftUI
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins
import PencilKit

struct PhotoEditorView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var originalImage: UIImage?
    @State private var filteredImage: UIImage?
    @State private var selectedFilter: ImageFilter = .none
    @State private var showDrawing = false
    @State private var canvasView = PKCanvasView()
    @State private var showOCRResult = false
    @State private var ocrText = ""
    
    private let context = CIContext()
    
    enum ImageFilter: String, CaseIterable {
        case none = "원본"
        case sepia = "세피아"
        case mono = "흑백"
        case vignette = "비네트"
        case bloom = "블룸"
        case chrome = "크롬"
        
        var icon: String {
            switch self {
            case .none: return "photo"
            case .sepia: return "camera.filters"
            case .mono: return "circle.lefthalf.filled"
            case .vignette: return "circle.dashed"
            case .bloom: return "sun.max"
            case .chrome: return "sparkles"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 이미지 영역
                ZStack {
                    if let image = filteredImage ?? originalImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                        
                        if showDrawing {
                            DrawingCanvas(canvasView: $canvasView)
                        }
                    } else {
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            VStack(spacing: 16) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 60))
                                Text("사진 선택")
                                    .font(.headline)
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
                
                // 필터 선택
                if originalImage != nil {
                    filterSelector
                }
            }
            .navigationTitle("PhotoLab")
            .toolbar {
                if originalImage != nil {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button {
                            showDrawing.toggle()
                        } label: {
                            Image(systemName: showDrawing ? "pencil.circle.fill" : "pencil.circle")
                        }
                        
                        Button {
                            performOCR()
                        } label: {
                            Image(systemName: "text.viewfinder")
                        }
                        
                        Button {
                            saveImage()
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                        }
                    }
                }
            }
            .onChange(of: selectedItem) { loadImage() }
            .onChange(of: selectedFilter) { applyFilter() }
            .sheet(isPresented: $showOCRResult) {
                OCRResultView(text: ocrText)
            }
        }
    }
    
    // MARK: - Filter Selector
    private var filterSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ImageFilter.allCases, id: \.self) { filter in
                    FilterButton(
                        filter: filter,
                        isSelected: selectedFilter == filter
                    ) {
                        selectedFilter = filter
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Load Image
    private func loadImage() {
        Task {
            if let data = try? await selectedItem?.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                originalImage = image
                filteredImage = nil
                selectedFilter = .none
            }
        }
    }
    
    // MARK: - Apply Filter
    private func applyFilter() {
        guard let original = originalImage,
              let ciImage = CIImage(image: original) else { return }
        
        var outputImage: CIImage = ciImage
        
        switch selectedFilter {
        case .none:
            filteredImage = nil
            return
            
        case .sepia:
            let filter = CIFilter.sepiaTone()
            filter.inputImage = ciImage
            filter.intensity = 0.8
            outputImage = filter.outputImage ?? ciImage
            
        case .mono:
            let filter = CIFilter.photoEffectMono()
            filter.inputImage = ciImage
            outputImage = filter.outputImage ?? ciImage
            
        case .vignette:
            let filter = CIFilter.vignette()
            filter.inputImage = ciImage
            filter.intensity = 1.5
            filter.radius = 2.0
            outputImage = filter.outputImage ?? ciImage
            
        case .bloom:
            let filter = CIFilter.bloom()
            filter.inputImage = ciImage
            filter.intensity = 0.5
            filter.radius = 10
            outputImage = filter.outputImage ?? ciImage
            
        case .chrome:
            let filter = CIFilter.photoEffectChrome()
            filter.inputImage = ciImage
            outputImage = filter.outputImage ?? ciImage
        }
        
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            filteredImage = UIImage(cgImage: cgImage)
        }
    }
    
    // MARK: - OCR
    private func performOCR() {
        guard let image = filteredImage ?? originalImage,
              let cgImage = image.cgImage else { return }
        
        let request = VNRecognizeTextRequest { request, _ in
            let observations = request.results as? [VNRecognizedTextObservation] ?? []
            ocrText = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
            showOCRResult = true
        }
        request.recognitionLanguages = ["ko-KR", "en-US"]
        
        try? VNImageRequestHandler(cgImage: cgImage).perform([request])
    }
    
    // MARK: - Save
    private func saveImage() {
        guard let image = filteredImage ?? originalImage else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}

// MARK: - Filter Button
struct FilterButton: View {
    let filter: PhotoEditorView.ImageFilter
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: filter.icon)
                    .font(.title2)
                Text(filter.rawValue)
                    .font(.caption)
            }
            .frame(width: 70, height: 70)
            .background(isSelected ? Color.accentColor : Color(.systemGray5))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Drawing Canvas
struct DrawingCanvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.tool = PKInkingTool(.pen, color: .red, width: 5)
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}

// MARK: - OCR Result
struct OCRResultView: View {
    @Environment(\.dismiss) private var dismiss
    let text: String
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text(text.isEmpty ? "텍스트를 찾을 수 없습니다." : text)
                    .padding()
            }
            .navigationTitle("인식된 텍스트")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") { dismiss() }
                }
                if !text.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            UIPasteboard.general.string = text
                        } label: {
                            Image(systemName: "doc.on.doc")
                        }
                    }
                }
            }
        }
    }
}

import Vision

#Preview {
    PhotoEditorView()
}
