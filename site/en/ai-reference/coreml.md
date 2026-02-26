# Core ML AI Reference

> 온디바이스 머신러닝 가이드. 이 문서를 읽고 Core ML 코드를 생성할 수 있습니다.

## 개요

Core ML은 학습된 ML 모델을 앱에서 실행하는 프레임워크입니다.
이미지 분류, 객체 감지, 자연어 처리 등 다양한 ML 작업을 온디바이스에서 수행합니다.

## 필수 Import

```swift
import CoreML
import Vision  // 이미지 분석 시
```

## 핵심 구성요소

### 1. 모델 로드

```swift
// 1. 번들된 모델 (컴파일된 .mlmodelc)
let model = try? MyImageClassifier(configuration: MLModelConfiguration())

// 2. 동적 로드 (URL에서)
let modelURL = Bundle.main.url(forResource: "MyModel", withExtension: "mlmodelc")!
let model = try MLModel(contentsOf: modelURL)

// 3. 백그라운드에서 컴파일
let sourceURL = Bundle.main.url(forResource: "MyModel", withExtension: "mlmodel")!
let compiledURL = try await MLModel.compileModel(at: sourceURL)
let model = try MLModel(contentsOf: compiledURL)
```

### 2. 모델 설정

```swift
let config = MLModelConfiguration()

// 연산 장치 선택
config.computeUnits = .all        // CPU + GPU + Neural Engine
config.computeUnits = .cpuOnly    // CPU만
config.computeUnits = .cpuAndGPU  // Neural Engine 제외

// GPU 허용
config.allowLowPrecisionAccumulationOnGPU = true

let model = try MyModel(configuration: config)
```

### 3. Vision + Core ML

```swift
func classifyImage(_ image: UIImage) async throws -> [(String, Float)] {
    guard let cgImage = image.cgImage else { throw ClassificationError.invalidImage }
    
    // Core ML 모델을 Vision 모델로 래핑
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

## 전체 작동 예제

### 이미지 분류기

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
            // MobileNetV2 모델 사용 (Apple 제공)
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
                // 이미지 선택
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Group {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                        } else {
                            ContentUnavailableView("이미지 선택", systemImage: "photo", description: Text("분류할 이미지를 선택하세요"))
                        }
                    }
                    .frame(maxHeight: 300)
                }
                
                // 결과
                if classifier.isProcessing {
                    ProgressView("분석 중...")
                } else if !classifier.predictions.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("분류 결과")
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
            .navigationTitle("이미지 분류")
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

### 텍스트 분류

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
                self.sentiment = "긍정적 😊"
            } else if score < -0.1 {
                self.sentiment = "부정적 😞"
            } else {
                self.sentiment = "중립적 😐"
            }
        }
    }
}
```

## 고급 패턴

### 1. 커스텀 모델 사용

```swift
// 1. Create ML로 학습한 모델
// 2. Xcode 프로젝트에 .mlmodel 파일 추가
// 3. 자동 생성된 클래스 사용

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

### 2. 실시간 카메라 분류

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

### 3. 모델 업데이트 (On-Device Training)

```swift
// Updatable 모델 필요 (.mlmodel에서 설정)
func updateModel(with trainingData: MLBatchProvider) async throws {
    let modelURL = Bundle.main.url(forResource: "UpdatableModel", withExtension: "mlmodelc")!
    
    let updateTask = try MLUpdateTask(
        forModelAt: modelURL,
        trainingData: trainingData,
        configuration: nil,
        completionHandler: { context in
            // 업데이트된 모델 저장
            let updatedModelURL = context.model.modelDescription.metadata[MLModelMetadataKey.creatorDefinedKey(key: "updatedModelURL")]
        }
    )
    
    updateTask.resume()
}
```

## 주의사항

1. **모델 크기**
   - 앱 번들 크기에 영향
   - 큰 모델은 On-Demand Resources 고려
   - 양자화로 크기 축소 가능

2. **성능 최적화**
   ```swift
   // Neural Engine 우선 사용
   config.computeUnits = .all
   
   // 저전력 모드에서 CPU만
   if ProcessInfo.processInfo.isLowPowerModeEnabled {
       config.computeUnits = .cpuOnly
   }
   ```

3. **입력 전처리**
   - 모델이 요구하는 이미지 크기로 리사이즈
   - 정규화 필요한 경우 직접 처리
   - Vision 사용 시 자동 처리됨

4. **에러 처리**
   ```swift
   do {
       let prediction = try model.prediction(input: input)
   } catch MLModelError.generic {
       // 일반 오류
   } catch MLModelError.io {
       // 입출력 오류
   } catch {
       // 기타 오류
   }
   ```
