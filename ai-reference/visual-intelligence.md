# Visual Intelligence AI Reference

> Apple Intelligence 시각 분석 가이드. 이 문서를 읽고 Visual Intelligence 코드를 생성할 수 있습니다.

## 개요

Visual Intelligence는 iOS 18.1+에서 제공하는 Apple Intelligence 기능으로,
카메라 컨트롤 버튼을 통해 실세계 객체를 인식하고 정보를 제공합니다.
앱에서 직접 호출하는 API는 제한적이며, 주로 시스템 기능으로 동작합니다.

## 필수 Import

```swift
import Vision        // 이미지 분석
import VisionKit     // 라이브 텍스트, 시각 조회
import UIKit
```

## 핵심 기능

Visual Intelligence는 다음을 포함합니다:
- **시각 조회 (Visual Look Up)**: 이미지 내 객체 정보 조회
- **라이브 텍스트 (Live Text)**: 실시간 텍스트 인식
- **피사체 분리 (Subject Lifting)**: 배경에서 피사체 추출

## 핵심 구성요소

### 1. ImageAnalyzer (VisionKit)

```swift
import VisionKit

// 이미지 분석기
let analyzer = ImageAnalyzer()
let configuration = ImageAnalyzer.Configuration([.text, .visualLookUp])

// 분석 실행
func analyzeImage(_ image: UIImage) async throws -> ImageAnalysis {
    try await analyzer.analyze(image, configuration: configuration)
}
```

### 2. ImageAnalysisInteraction (시각 조회)

```swift
import VisionKit

// UIImageView에 상호작용 추가
let interaction = ImageAnalysisInteraction()
imageView.addInteraction(interaction)

// 분석 결과 설정
interaction.analysis = analysisResult
interaction.preferredInteractionTypes = [.visualLookUp, .textSelection]
```

### 3. 피사체 분리

```swift
// iOS 16+
func extractSubject(from image: UIImage) async throws -> UIImage? {
    guard let cgImage = image.cgImage else { return nil }
    
    let analysis = try await analyzer.analyze(image, configuration: configuration)
    
    // 피사체 이미지 추출
    guard let subject = try await analysis.subjects.first?.image else { return nil }
    
    return UIImage(cgImage: subject)
}
```

## 전체 작동 예제

```swift
import SwiftUI
import VisionKit
import PhotosUI

// MARK: - Visual Intelligence Manager
@Observable
class VisualIntelligenceManager {
    var selectedImage: UIImage?
    var analysis: ImageAnalysis?
    var isAnalyzing = false
    var errorMessage: String?
    var extractedSubject: UIImage?
    var recognizedText: String = ""
    var visualLookUpAvailable = false
    
    private let analyzer = ImageAnalyzer()
    
    var isSupported: Bool {
        ImageAnalyzer.isSupported
    }
    
    func analyze(_ image: UIImage) async {
        guard ImageAnalyzer.isSupported else {
            errorMessage = "이 기기에서는 이미지 분석을 사용할 수 없습니다"
            return
        }
        
        isAnalyzing = true
        errorMessage = nil
        extractedSubject = nil
        recognizedText = ""
        
        do {
            let configuration = ImageAnalyzer.Configuration([.text, .visualLookUp])
            let result = try await analyzer.analyze(image, configuration: configuration)
            
            analysis = result
            
            // 텍스트 추출
            recognizedText = result.transcript
            
            // 시각 조회 가능 여부
            visualLookUpAvailable = !result.subjects.isEmpty
            
        } catch {
            errorMessage = "분석 실패: \(error.localizedDescription)"
        }
        
        isAnalyzing = false
    }
    
    func extractSubject() async {
        guard let image = selectedImage,
              let analysis = analysis else { return }
        
        do {
            if let subject = analysis.subjects.first {
                let subjectImage = try await subject.image
                extractedSubject = UIImage(cgImage: subjectImage)
            }
        } catch {
            errorMessage = "피사체 추출 실패: \(error.localizedDescription)"
        }
    }
}

// MARK: - Image Analysis View (UIKit Wrapper)
struct ImageAnalysisView: UIViewRepresentable {
    let image: UIImage
    let analysis: ImageAnalysis?
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        let interaction = ImageAnalysisInteraction()
        interaction.preferredInteractionTypes = [.visualLookUp, .textSelection]
        imageView.addInteraction(interaction)
        
        context.coordinator.interaction = interaction
        
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        uiView.image = image
        context.coordinator.interaction?.analysis = analysis
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var interaction: ImageAnalysisInteraction?
    }
}

// MARK: - Main View
struct VisualIntelligenceView: View {
    @State private var manager = VisualIntelligenceManager()
    @State private var selectedItem: PhotosPickerItem?
    @State private var showSubjectSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 지원 여부
                    if !manager.isSupported {
                        ContentUnavailableView(
                            "지원되지 않는 기기",
                            systemImage: "eye.slash",
                            description: Text("이 기기에서는 Visual Intelligence를 사용할 수 없습니다")
                        )
                    }
                    
                    // 이미지 선택
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        if let image = manager.selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.quaternary)
                                .frame(height: 200)
                                .overlay {
                                    VStack(spacing: 8) {
                                        Image(systemName: "photo.badge.plus")
                                            .font(.largeTitle)
                                        Text("이미지 선택")
                                    }
                                    .foregroundStyle(.secondary)
                                }
                        }
                    }
                    .padding(.horizontal)
                    
                    // 분석 중
                    if manager.isAnalyzing {
                        ProgressView("분석 중...")
                    }
                    
                    // 에러
                    if let error = manager.errorMessage {
                        Label(error, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                            .padding()
                    }
                    
                    // 분석 결과
                    if let image = manager.selectedImage, manager.analysis != nil {
                        VStack(alignment: .leading, spacing: 16) {
                            // 인터랙티브 이미지 (시각 조회 가능)
                            Text("이미지를 탭하여 시각 조회")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            ImageAnalysisView(
                                image: image,
                                analysis: manager.analysis
                            )
                            .frame(height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            // 인식된 텍스트
                            if !manager.recognizedText.isEmpty {
                                GroupBox("인식된 텍스트") {
                                    Text(manager.recognizedText)
                                        .textSelection(.enabled)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            
                            // 피사체 분리
                            if manager.visualLookUpAvailable {
                                Button {
                                    Task {
                                        await manager.extractSubject()
                                        showSubjectSheet = true
                                    }
                                } label: {
                                    Label("피사체 분리", systemImage: "person.crop.rectangle")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Visual Intelligence")
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        manager.selectedImage = image
                        await manager.analyze(image)
                    }
                }
            }
            .sheet(isPresented: $showSubjectSheet) {
                if let subject = manager.extractedSubject {
                    NavigationStack {
                        VStack {
                            Image(uiImage: subject)
                                .resizable()
                                .scaledToFit()
                                .padding()
                            
                            ShareLink(
                                item: Image(uiImage: subject),
                                preview: SharePreview("추출된 피사체", image: Image(uiImage: subject))
                            ) {
                                Label("공유", systemImage: "square.and.arrow.up")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .padding()
                        }
                        .navigationTitle("피사체")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("닫기") {
                                    showSubjectSheet = false
                                }
                            }
                        }
                    }
                    .presentationDetents([.medium])
                }
            }
        }
    }
}

#Preview {
    VisualIntelligenceView()
}
```

## 고급 패턴

### 1. 라이브 텍스트 (DataScannerViewController)

```swift
import VisionKit

struct LiveTextScanner: UIViewControllerRepresentable {
    @Binding var recognizedText: String
    @Binding var isPresented: Bool
    
    static var isSupported: Bool {
        DataScannerViewController.isSupported
    }
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .balanced,
            recognizesMultipleItems: true,
            isHighFrameRateTrackingEnabled: false,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        if isPresented {
            try? uiViewController.startScanning()
        } else {
            uiViewController.stopScanning()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let parent: LiveTextScanner
        
        init(_ parent: LiveTextScanner) {
            self.parent = parent
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text):
                parent.recognizedText = text.transcript
            default:
                break
            }
        }
    }
}
```

### 2. VNRecognizeTextRequest (Vision)

```swift
import Vision

func recognizeText(in image: UIImage) async throws -> String {
    guard let cgImage = image.cgImage else {
        throw NSError(domain: "ImageError", code: -1)
    }
    
    return try await withCheckedThrowingContinuation { continuation in
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                continuation.resume(throwing: error)
                return
            }
            
            let observations = request.results as? [VNRecognizedTextObservation] ?? []
            let text = observations
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: "\n")
            
            continuation.resume(returning: text)
        }
        
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["ko-KR", "en-US"]
        
        let handler = VNImageRequestHandler(cgImage: cgImage)
        
        do {
            try handler.perform([request])
        } catch {
            continuation.resume(throwing: error)
        }
    }
}
```

### 3. 객체 분류 (VNClassifyImageRequest)

```swift
import Vision

func classifyImage(_ image: UIImage) async throws -> [String] {
    guard let cgImage = image.cgImage else { return [] }
    
    return try await withCheckedThrowingContinuation { continuation in
        let request = VNClassifyImageRequest { request, error in
            if let error = error {
                continuation.resume(throwing: error)
                return
            }
            
            let observations = request.results as? [VNClassificationObservation] ?? []
            let labels = observations
                .filter { $0.confidence > 0.5 }
                .prefix(5)
                .map { $0.identifier }
            
            continuation.resume(returning: Array(labels))
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage)
        
        do {
            try handler.perform([request])
        } catch {
            continuation.resume(throwing: error)
        }
    }
}
```

### 4. 바코드/QR 스캔

```swift
struct BarcodeScanner: UIViewControllerRepresentable {
    @Binding var scannedCode: String?
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [
                .barcode(symbologies: [.qr, .ean13, .ean8, .code128])
            ],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        try? scanner.startScanning()
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let parent: BarcodeScanner
        
        init(_ parent: BarcodeScanner) {
            self.parent = parent
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .barcode(let barcode):
                parent.scannedCode = barcode.payloadStringValue
            default:
                break
            }
        }
    }
}
```

## 주의사항

1. **기기 요구사항**
   ```swift
   // 지원 여부 확인
   guard ImageAnalyzer.isSupported else { return }
   guard DataScannerViewController.isSupported else { return }
   ```

2. **Apple Silicon 요구**
   - Visual Intelligence (카메라 컨트롤): iPhone 16 시리즈만
   - 이미지 분석: A12 Bionic 이상

3. **카메라 컨트롤**
   - 시스템 기능으로만 호출 가능
   - 앱에서 직접 트리거 불가

4. **개인정보**
   - 분석은 온디바이스 처리
   - 이미지가 서버로 전송되지 않음

5. **시뮬레이터**
   - DataScannerViewController 미지원
   - 이미지 분석은 일부 지원
