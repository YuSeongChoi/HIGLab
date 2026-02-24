# Visual Intelligence AI Reference

> Apple Intelligence visual analysis guide. Read this document to generate Visual Intelligence code.

## Overview

Visual Intelligence is an Apple Intelligence feature available in iOS 18.1+,
which recognizes real-world objects and provides information through the Camera Control button.
Direct API calls from apps are limited, and it primarily operates as a system feature.

## Required Import

```swift
import Vision        // Image analysis
import VisionKit     // Live Text, Visual Look Up
import UIKit
```

## Core Features

Visual Intelligence includes:
- **Visual Look Up**: Look up information about objects in images
- **Live Text**: Real-time text recognition
- **Subject Lifting**: Extract subjects from backgrounds

## Core Components

### 1. ImageAnalyzer (VisionKit)

```swift
import VisionKit

// Image analyzer
let analyzer = ImageAnalyzer()
let configuration = ImageAnalyzer.Configuration([.text, .visualLookUp])

// Perform analysis
func analyzeImage(_ image: UIImage) async throws -> ImageAnalysis {
    try await analyzer.analyze(image, configuration: configuration)
}
```

### 2. ImageAnalysisInteraction (Visual Look Up)

```swift
import VisionKit

// Add interaction to UIImageView
let interaction = ImageAnalysisInteraction()
imageView.addInteraction(interaction)

// Set analysis result
interaction.analysis = analysisResult
interaction.preferredInteractionTypes = [.visualLookUp, .textSelection]
```

### 3. Subject Lifting

```swift
// iOS 16+
func extractSubject(from image: UIImage) async throws -> UIImage? {
    guard let cgImage = image.cgImage else { return nil }
    
    let analysis = try await analyzer.analyze(image, configuration: configuration)
    
    // Extract subject image
    guard let subject = try await analysis.subjects.first?.image else { return nil }
    
    return UIImage(cgImage: subject)
}
```

## Complete Working Example

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
            errorMessage = "Image analysis is not available on this device"
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
            
            // Extract text
            recognizedText = result.transcript
            
            // Visual Look Up availability
            visualLookUpAvailable = !result.subjects.isEmpty
            
        } catch {
            errorMessage = "Analysis failed: \(error.localizedDescription)"
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
            errorMessage = "Subject extraction failed: \(error.localizedDescription)"
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
                    // Support check
                    if !manager.isSupported {
                        ContentUnavailableView(
                            "Unsupported Device",
                            systemImage: "eye.slash",
                            description: Text("Visual Intelligence is not available on this device")
                        )
                    }
                    
                    // Image selection
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
                                        Text("Select Image")
                                    }
                                    .foregroundStyle(.secondary)
                                }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Analyzing
                    if manager.isAnalyzing {
                        ProgressView("Analyzing...")
                    }
                    
                    // Error
                    if let error = manager.errorMessage {
                        Label(error, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                            .padding()
                    }
                    
                    // Analysis results
                    if let image = manager.selectedImage, manager.analysis != nil {
                        VStack(alignment: .leading, spacing: 16) {
                            // Interactive image (Visual Look Up available)
                            Text("Tap the image for Visual Look Up")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            ImageAnalysisView(
                                image: image,
                                analysis: manager.analysis
                            )
                            .frame(height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            // Recognized text
                            if !manager.recognizedText.isEmpty {
                                GroupBox("Recognized Text") {
                                    Text(manager.recognizedText)
                                        .textSelection(.enabled)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            
                            // Subject lifting
                            if manager.visualLookUpAvailable {
                                Button {
                                    Task {
                                        await manager.extractSubject()
                                        showSubjectSheet = true
                                    }
                                } label: {
                                    Label("Extract Subject", systemImage: "person.crop.rectangle")
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
                                preview: SharePreview("Extracted Subject", image: Image(uiImage: subject))
                            ) {
                                Label("Share", systemImage: "square.and.arrow.up")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .padding()
                        }
                        .navigationTitle("Subject")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Close") {
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

## Advanced Patterns

### 1. Live Text (DataScannerViewController)

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

### 3. Object Classification (VNClassifyImageRequest)

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

### 4. Barcode/QR Scanning

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

## Important Notes

1. **Device Requirements**
   ```swift
   // Check support
   guard ImageAnalyzer.isSupported else { return }
   guard DataScannerViewController.isSupported else { return }
   ```

2. **Apple Silicon Required**
   - Visual Intelligence (Camera Control): iPhone 16 series only
   - Image analysis: A12 Bionic or later

3. **Camera Control**
   - Can only be invoked as a system feature
   - Cannot be triggered directly from apps

4. **Privacy**
   - Analysis is processed on-device
   - Images are not sent to servers

5. **Simulator**
   - DataScannerViewController not supported
   - Image analysis partially supported
