# Core ML AI Reference

> On-device machine learning guide. Read this document to generate Core ML code.

## Overview

Core ML is a framework for running trained ML models in apps.
It performs various ML tasks on-device including image classification, object detection, natural language processing, and more.

## Required Imports

```swift
import CoreML
import Vision  // For image analysis
```

## Core Components

### 1. Loading Models

```swift
// 1. Bundled model (compiled .mlmodelc)
let model = try? MyImageClassifier(configuration: MLModelConfiguration())

// 2. Dynamic load (from URL)
let modelURL = Bundle.main.url(forResource: "MyModel", withExtension: "mlmodelc")!
let model = try MLModel(contentsOf: modelURL)

// 3. Compile in background
let sourceURL = Bundle.main.url(forResource: "MyModel", withExtension: "mlmodel")!
let compiledURL = try await MLModel.compileModel(at: sourceURL)
let model = try MLModel(contentsOf: compiledURL)
```

### 2. Model Configuration

```swift
let config = MLModelConfiguration()

// Select compute device
config.computeUnits = .all        // CPU + GPU + Neural Engine
config.computeUnits = .cpuOnly    // CPU only
config.computeUnits = .cpuAndGPU  // Exclude Neural Engine

// Allow GPU
config.allowLowPrecisionAccumulationOnGPU = true

let model = try MyModel(configuration: config)
```

### 3. Vision + Core ML

```swift
func classifyImage(_ image: UIImage) async throws -> [(String, Float)] {
    guard let cgImage = image.cgImage else { throw ClassificationError.invalidImage }
    
    // Wrap Core ML model with Vision model
    let model = try VNCoreMLModel(for: MobileNetV2().model)
    
    let request = VNCoreMLRequest(model: model)
    request.imageCropAndScaleOption = .centerCrop
    
    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    try handler.perform([request])
    
    guard let results = request.results as? [VNClassificationObservation] else {
        throw ClassificationError.noResults
    }
    
    return results.prefix(5).map { ($0.identifier, $0.confidence) }
}
```

## Complete Working Example

### Image Classifier

```swift
import SwiftUI
import CoreML
import Vision
import PhotosUI

// MARK: - Classifier
@Observable
class ImageClassifier {
    var predictions: [(label: String, confidence: Float)] = []
    var isProcessing = false
    var error: Error?
    
    private var model: VNCoreMLModel?
    
    init() {
        setupModel()
    }
    
    private func setupModel() {
        do {
            // Use MobileNetV2 model (Apple provided)
            let config = MLModelConfiguration()
            config.computeUnits = .all
            let coreMLModel = try MobileNetV2(configuration: config).model
            model = try VNCoreMLModel(for: coreMLModel)
        } catch {
            self.error = error
        }
    }
    
    func classify(_ image: UIImage) async {
        guard let cgImage = image.cgImage, let model = model else { return }
        
        isProcessing = true
        defer { isProcessing = false }
        
        let request = VNCoreMLRequest(model: model)
        request.imageCropAndScaleOption = .centerCrop
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
            
            if let results = request.results as? [VNClassificationObservation] {
                await MainActor.run {
                    predictions = results.prefix(5).map { 
                        (label: $0.identifier.components(separatedBy: ",").first ?? $0.identifier, 
                         confidence: $0.confidence) 
                    }
                }
            }
        } catch {
            await MainActor.run {
                self.error = error
            }
        }
    }
}

// MARK: - View
struct ImageClassifierView: View {
    @State private var classifier = ImageClassifier()
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Image selection
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Group {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                        } else {
                            ContentUnavailableView("Select Image", systemImage: "photo", description: Text("Select an image to classify"))
                        }
                    }
                    .frame(maxHeight: 300)
                }
                
                // Results
                if classifier.isProcessing {
                    ProgressView("Analyzing...")
                } else if !classifier.predictions.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Classification Results")
                            .font(.headline)
                        
                        ForEach(classifier.predictions, id: \.label) { prediction in
                            HStack {
                                Text(prediction.label)
                                Spacer()
                                Text("\(Int(prediction.confidence * 100))%")
                                    .foregroundStyle(.secondary)
                            }
                            
                            ProgressView(value: prediction.confidence)
                                .tint(prediction.confidence > 0.5 ? .green : .orange)
                        }
                    }
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Image Classification")
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                        await classifier.classify(image)
                    }
                }
            }
        }
    }
}
```

### Text Classification

```swift
import NaturalLanguage

@Observable
class SentimentAnalyzer {
    var sentiment: String = ""
    var confidence: Double = 0
    
    func analyze(_ text: String) {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        
        let (sentiment, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
        
        if let sentimentScore = sentiment?.rawValue, let score = Double(sentimentScore) {
            self.confidence = abs(score)
            if score > 0.1 {
                self.sentiment = "Positive 😊"
            } else if score < -0.1 {
                self.sentiment = "Negative 😞"
            } else {
                self.sentiment = "Neutral 😐"
            }
        }
    }
}
```

## Advanced Patterns

### 1. Using Custom Models

```swift
// 1. Model trained with Create ML
// 2. Add .mlmodel file to Xcode project
// 3. Use auto-generated class

class CustomClassifier {
    let model: MyCustomModel
    
    init() throws {
        let config = MLModelConfiguration()
        model = try MyCustomModel(configuration: config)
    }
    
    func predict(input: MLMultiArray) throws -> MyCustomModelOutput {
        let input = MyCustomModelInput(features: input)
        return try model.prediction(input: input)
    }
}
```

### 2. Real-time Camera Classification

```swift
import AVFoundation

class CameraClassifier: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var onPrediction: ([(String, Float)]) -> Void = { _ in }
    
    private let model: VNCoreMLModel
    private let captureSession = AVCaptureSession()
    
    init() throws {
        let coreModel = try MobileNetV2(configuration: MLModelConfiguration()).model
        model = try VNCoreMLModel(for: coreModel)
        super.init()
        setupCamera()
    }
    
    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        captureSession.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "ml.queue"))
        captureSession.addOutput(output)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNCoreMLRequest(model: model) { [weak self] request, _ in
            guard let results = request.results as? [VNClassificationObservation] else { return }
            let predictions = results.prefix(3).map { ($0.identifier, $0.confidence) }
            
            DispatchQueue.main.async {
                self?.onPrediction(predictions)
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
}
```

### 3. Model Update (On-Device Training)

```swift
// Requires updatable model (configured in .mlmodel)
func updateModel(with trainingData: MLBatchProvider) async throws {
    let modelURL = Bundle.main.url(forResource: "UpdatableModel", withExtension: "mlmodelc")!
    
    let updateTask = try MLUpdateTask(
        forModelAt: modelURL,
        trainingData: trainingData,
        configuration: nil,
        completionHandler: { context in
            // Save updated model
            let updatedModelURL = context.model.modelDescription.metadata[MLModelMetadataKey.creatorDefinedKey(key: "updatedModelURL")]
        }
    )
    
    updateTask.resume()
}
```

## Important Notes

1. **Model Size**
   - Affects app bundle size
   - Consider On-Demand Resources for large models
   - Quantization can reduce size

2. **Performance Optimization**
   ```swift
   // Prefer Neural Engine
   config.computeUnits = .all
   
   // CPU only in low power mode
   if ProcessInfo.processInfo.isLowPowerModeEnabled {
       config.computeUnits = .cpuOnly
   }
   ```

3. **Input Preprocessing**
   - Resize to image size required by model
   - Handle normalization if needed
   - Vision handles this automatically

4. **Error Handling**
   ```swift
   do {
       let prediction = try model.prediction(input: input)
   } catch MLModelError.generic {
       // General error
   } catch MLModelError.io {
       // I/O error
   } catch {
       // Other errors
   }
   ```
