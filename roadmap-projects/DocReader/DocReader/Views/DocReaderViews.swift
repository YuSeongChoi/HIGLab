import SwiftUI
import PDFKit
import Vision
import VisionKit
import UniformTypeIdentifiers

// MARK: - Document List View
struct DocumentListView: View {
    @State private var documents: [URL] = []
    @State private var showFilePicker = false
    @State private var selectedDocument: URL?
    
    var body: some View {
        NavigationStack {
            Group {
                if documents.isEmpty {
                    ContentUnavailableView(
                        "문서가 없습니다",
                        systemImage: "doc.text",
                        description: Text("PDF 파일을 추가하세요")
                    )
                } else {
                    List(documents, id: \.self) { url in
                        Button {
                            selectedDocument = url
                        } label: {
                            HStack {
                                Image(systemName: "doc.fill")
                                    .foregroundStyle(.red)
                                Text(url.lastPathComponent)
                            }
                        }
                    }
                }
            }
            .navigationTitle("문서")
            .toolbar {
                Button {
                    showFilePicker = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [.pdf]
            ) { result in
                if case .success(let url) = result {
                    documents.append(url)
                }
            }
            .fullScreenCover(item: $selectedDocument) { url in
                PDFReaderView(url: url)
            }
        }
    }
}

extension URL: Identifiable {
    public var id: String { absoluteString }
}

// MARK: - PDF Reader View
struct PDFReaderView: View {
    @Environment(\.dismiss) private var dismiss
    let url: URL
    
    @State private var extractedText = ""
    @State private var showText = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            PDFViewRepresentable(url: url, searchText: searchText)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle(url.lastPathComponent)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("닫기") { dismiss() }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            extractText()
                        } label: {
                            Image(systemName: "text.viewfinder")
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "텍스트 검색")
                .sheet(isPresented: $showText) {
                    ExtractedTextView(text: extractedText)
                }
        }
    }
    
    private func extractText() {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        
        guard let document = PDFDocument(url: url) else { return }
        
        var fullText = ""
        for i in 0..<document.pageCount {
            if let page = document.page(at: i),
               let text = page.string {
                fullText += text + "\n\n"
            }
        }
        
        extractedText = fullText
        showText = true
    }
}

// MARK: - PDF View Representable
struct PDFViewRepresentable: UIViewRepresentable {
    let url: URL
    let searchText: String
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        
        if url.startAccessingSecurityScopedResource() {
            pdfView.document = PDFDocument(url: url)
            url.stopAccessingSecurityScopedResource()
        }
        
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        if !searchText.isEmpty {
            if let selection = pdfView.document?.findString(searchText, withOptions: .caseInsensitive).first {
                pdfView.go(to: selection)
                pdfView.setCurrentSelection(selection, animate: true)
            }
        } else {
            pdfView.clearSelection()
        }
    }
}

// MARK: - Extracted Text View
struct ExtractedTextView: View {
    @Environment(\.dismiss) private var dismiss
    let text: String
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text(text.isEmpty ? "텍스트를 추출할 수 없습니다." : text)
                    .padding()
                    .textSelection(.enabled)
            }
            .navigationTitle("추출된 텍스트")
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

// MARK: - Scanner View
struct ScannerView: View {
    @State private var showScanner = false
    @State private var scannedImages: [UIImage] = []
    @State private var recognizedText = ""
    @State private var showText = false
    @State private var isProcessing = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if scannedImages.isEmpty {
                    ContentUnavailableView(
                        "스캔된 문서가 없습니다",
                        systemImage: "doc.text.viewfinder",
                        description: Text("문서를 스캔하세요")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(scannedImages.indices, id: \.self) { index in
                                Image(uiImage: scannedImages[index])
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("스캔")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !scannedImages.isEmpty {
                        Button {
                            performOCR()
                        } label: {
                            if isProcessing {
                                ProgressView()
                            } else {
                                Image(systemName: "text.viewfinder")
                            }
                        }
                        .disabled(isProcessing)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showScanner = true
                    } label: {
                        Image(systemName: "camera")
                    }
                }
            }
            .sheet(isPresented: $showScanner) {
                DocumentScannerView { images in
                    scannedImages = images
                }
            }
            .sheet(isPresented: $showText) {
                ExtractedTextView(text: recognizedText)
            }
        }
    }
    
    private func performOCR() {
        isProcessing = true
        
        Task {
            var allText = ""
            
            for image in scannedImages {
                guard let cgImage = image.cgImage else { continue }
                
                let request = VNRecognizeTextRequest { request, _ in
                    let observations = request.results as? [VNRecognizedTextObservation] ?? []
                    let text = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
                    allText += text + "\n\n"
                }
                request.recognitionLanguages = ["ko-KR", "en-US"]
                request.recognitionLevel = .accurate
                
                try? VNImageRequestHandler(cgImage: cgImage).perform([request])
            }
            
            await MainActor.run {
                recognizedText = allText
                isProcessing = false
                showText = true
            }
        }
    }
}

// MARK: - Document Scanner
struct DocumentScannerView: UIViewControllerRepresentable {
    let completion: ([UIImage]) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let controller = VNDocumentCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion, dismiss: dismiss)
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let completion: ([UIImage]) -> Void
        let dismiss: DismissAction
        
        init(completion: @escaping ([UIImage]) -> Void, dismiss: DismissAction) {
            self.completion = completion
            self.dismiss = dismiss
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            var images: [UIImage] = []
            for i in 0..<scan.pageCount {
                images.append(scan.imageOfPage(at: i))
            }
            completion(images)
            dismiss()
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            dismiss()
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            dismiss()
        }
    }
}

#Preview {
    ContentView()
}
