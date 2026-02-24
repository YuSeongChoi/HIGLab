# Vision AI Reference

> Image analysis and computer vision guide. Read this document to generate Vision code.

## Overview

Vision is a framework for image and video analysis.
It supports face detection, text recognition (OCR), barcode scanning, image classification, and more.

## Required Import

```swift
import Vision
import UIKit  // or SwiftUI
```

## Core Components

### 1. Vision Request Structure

```swift
// 1. Create request
let request = VNRecognizeTextRequest { request, error in
    guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
    // Process results
}

// 2. Create handler
let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

// 3. Perform request
try handler.perform([request])
```

### 2. Major Request Types

```swift
// Text recognition (OCR)
let textRequest = VNRecognizeTextRequest()

// Face detection
let faceRequest = VNDetectFaceRectanglesRequest()

// Face landmarks (eyes, nose, mouth positions)
let landmarkRequest = VNDetectFaceLandmarksRequest()

// Barcode/QR detection
let barcodeRequest = VNDetectBarcodesRequest()

// Image classification
let classifyRequest = VNClassifyImageRequest()

// Object detection
let objectRequest = VNDetectRectanglesRequest()

// Human detection
let humanRequest = VNDetectHumanRectanglesRequest()
```

## Complete Working Example

### Text Recognition (OCR)

```swift
import SwiftUI
import Vision
import PhotosUI

@Observable
class TextRecognizer {
    var recognizedText = ""
    var isProcessing = false
    
    func recognizeText(from image: UIImage) async {
        guard let cgImage = image.cgImage else { return }
        
        isProcessing = true
        defer { isProcessing = false }
        
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate  // .fast also available
        request.recognitionLanguages = ["ko-KR", "en-US"]
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
            
            guard let observations = request.results else { return }
            
            let text = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            await MainActor.run {
                recognizedText = text
            }
        } catch {
            print("OCR failed: \(error)")
        }
    }
}

struct TextScannerView: View {
    @State private var recognizer = TextRecognizer()
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Image selection
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                    } else {
                        ContentUnavailableView("Select Image", systemImage: "photo", description: Text("Choose a photo"))
                    }
                }
                
                // Results
                if recognizer.isProcessing {
                    ProgressView("Recognizing text...")
                } else if !recognizer.recognizedText.isEmpty {
                    ScrollView {
                        Text(recognizer.recognizedText)
                            .textSelection(.enabled)
                            .padding()
                    }
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
            .navigationTitle("Text Scanner")
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                        await recognizer.recognizeText(from: image)
                    }
                }
            }
        }
    }
}
```

### Barcode/QR Scanner

```swift
import SwiftUI
import Vision
import AVFoundation

@Observable
class BarcodeScanner: NSObject {
    var scannedCode: String?
    var isScanning = false
    
    private var captureSession: AVCaptureSession?
    
    func scan(from image: UIImage) async {
        guard let cgImage = image.cgImage else { return }
        
        let request = VNDetectBarcodesRequest()
        request.symbologies = [.qr, .ean13, .code128]  // Supported barcode types
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
            
            if let observation = request.results?.first {
                await MainActor.run {
                    scannedCode = observation.payloadStringValue
                }
            }
        } catch {
            print("Barcode scan failed: \(error)")
        }
    }
}

// Real-time camera scanning
class CameraBarcodeScanner: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var onCodeDetected: ((String) -> Void)?
    
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let queue = DispatchQueue(label: "barcode.scanner")
    
    func startScanning() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        captureSession.addInput(input)
        
        videoOutput.setSampleBufferDelegate(self, queue: queue)
        captureSession.addOutput(videoOutput)
        
        captureSession.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNDetectBarcodesRequest { [weak self] request, error in
            if let result = request.results?.first as? VNBarcodeObservation,
               let payload = result.payloadStringValue {
                DispatchQueue.main.async {
                    self?.onCodeDetected?(payload)
                }
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
}
```

### Face Detection

```swift
@Observable
class FaceDetector {
    var faces: [VNFaceObservation] = []
    
    func detectFaces(in image: UIImage) async {
        guard let cgImage = image.cgImage else { return }
        
        let request = VNDetectFaceLandmarksRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
            
            await MainActor.run {
                faces = request.results ?? []
            }
        } catch {
            print("Face detection failed: \(error)")
        }
    }
}

// Convert face position to image coordinates
extension VNFaceObservation {
    func boundingBox(in imageSize: CGSize) -> CGRect {
        let box = self.boundingBox
        return CGRect(
            x: box.minX * imageSize.width,
            y: (1 - box.maxY) * imageSize.height,  // Vision uses bottom-left origin
            width: box.width * imageSize.width,
            height: box.height * imageSize.height
        )
    }
}
```

## Advanced Patterns

### 1. Document Scanning (iOS 13+)

```swift
import VisionKit

struct DocumentScannerView: UIViewControllerRepresentable {
    @Binding var scannedImages: [UIImage]
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let parent: DocumentScannerView
        
        init(_ parent: DocumentScannerView) {
            self.parent = parent
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            var images: [UIImage] = []
            for i in 0..<scan.pageCount {
                images.append(scan.imageOfPage(at: i))
            }
            parent.scannedImages = images
            controller.dismiss(animated: true)
        }
    }
}
```

### 2. Image Similarity Comparison

```swift
func compareImages(_ image1: UIImage, _ image2: UIImage) async -> Float? {
    guard let cgImage1 = image1.cgImage,
          let cgImage2 = image2.cgImage else { return nil }
    
    let request = VNGenerateImageFeaturePrintRequest()
    
    let handler1 = VNImageRequestHandler(cgImage: cgImage1, options: [:])
    let handler2 = VNImageRequestHandler(cgImage: cgImage2, options: [:])
    
    do {
        try handler1.perform([request])
        guard let print1 = request.results?.first as? VNFeaturePrintObservation else { return nil }
        
        let request2 = VNGenerateImageFeaturePrintRequest()
        try handler2.perform([request2])
        guard let print2 = request2.results?.first as? VNFeaturePrintObservation else { return nil }
        
        var distance: Float = 0
        try print1.computeDistance(&distance, to: print2)
        
        return distance  // Lower means more similar
    } catch {
        return nil
    }
}
```

### 3. Real-time Object Tracking

```swift
class ObjectTracker {
    private var sequenceHandler = VNSequenceRequestHandler()
    private var trackingRequest: VNTrackObjectRequest?
    
    func startTracking(observation: VNDetectedObjectObservation) {
        trackingRequest = VNTrackObjectRequest(detectedObjectObservation: observation) { [weak self] request, error in
            guard let result = request.results?.first as? VNDetectedObjectObservation else { return }
            // Update tracked position
        }
        trackingRequest?.trackingLevel = .accurate
    }
    
    func track(in pixelBuffer: CVPixelBuffer) {
        guard let request = trackingRequest else { return }
        try? sequenceHandler.perform([request], on: pixelBuffer)
    }
}
```

## Important Notes

1. **Coordinate System Conversion**
   - Vision: Bottom-left origin (0,0), normalized coordinates (0~1)
   - UIKit: Top-left origin
   - Need to convert `boundingBox` to image size

2. **Async Processing**
   - Image analysis is heavy → execute in background
   - UI updates on main thread

3. **Memory Management**
   - Resize large images before processing
   - Use `VNSequenceRequestHandler` for continuous frame processing

4. **Accuracy vs Speed**
   ```swift
   // Text recognition
   request.recognitionLevel = .accurate  // Accurate (slow)
   request.recognitionLevel = .fast      // Fast (less accurate)
   ```
