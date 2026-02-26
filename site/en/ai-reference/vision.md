# Vision AI Reference

> 이미지 분석 및 컴퓨터 비전 가이드. 이 문서를 읽고 Vision 코드를 생성할 수 있습니다.

## 개요

Vision은 이미지와 비디오 분석을 위한 프레임워크입니다.
얼굴 인식, 텍스트 인식(OCR), 바코드 스캔, 이미지 분류 등을 지원합니다.

## 필수 Import

```swift
import Vision
import UIKit  // 또는 SwiftUI
```

## 핵심 구성요소

### 1. Vision 요청 구조

```swift
// 1. 요청 생성
let request = VNRecognizeTextRequest { request, error in
    guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
    // 결과 처리
}

// 2. 핸들러 생성
let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

// 3. 요청 실행
try handler.perform([request])
```

### 2. 주요 요청 타입

```swift
// 텍스트 인식 (OCR)
let textRequest = VNRecognizeTextRequest()

// 얼굴 감지
let faceRequest = VNDetectFaceRectanglesRequest()

// 얼굴 랜드마크 (눈, 코, 입 위치)
let landmarkRequest = VNDetectFaceLandmarksRequest()

// 바코드/QR 감지
let barcodeRequest = VNDetectBarcodesRequest()

// 이미지 분류
let classifyRequest = VNClassifyImageRequest()

// 객체 감지
let objectRequest = VNDetectRectanglesRequest()

// 사람 감지
let humanRequest = VNDetectHumanRectanglesRequest()
```

## 전체 작동 예제

### 텍스트 인식 (OCR)

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
        request.recognitionLevel = .accurate  // .fast도 가능
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
            print("OCR 실패: \(error)")
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
                // 이미지 선택
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                    } else {
                        ContentUnavailableView("이미지 선택", systemImage: "photo", description: Text("사진을 선택하세요"))
                    }
                }
                
                // 결과
                if recognizer.isProcessing {
                    ProgressView("텍스트 인식 중...")
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
            .navigationTitle("텍스트 스캐너")
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

### 바코드/QR 스캐너

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
        request.symbologies = [.qr, .ean13, .code128]  // 지원할 바코드 타입
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
            
            if let observation = request.results?.first {
                await MainActor.run {
                    scannedCode = observation.payloadStringValue
                }
            }
        } catch {
            print("바코드 스캔 실패: \(error)")
        }
    }
}

// 실시간 카메라 스캔
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

### 얼굴 감지

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
            print("얼굴 감지 실패: \(error)")
        }
    }
}

// 얼굴 위치를 이미지 좌표로 변환
extension VNFaceObservation {
    func boundingBox(in imageSize: CGSize) -> CGRect {
        let box = self.boundingBox
        return CGRect(
            x: box.minX * imageSize.width,
            y: (1 - box.maxY) * imageSize.height,  // Vision은 좌하단 원점
            width: box.width * imageSize.width,
            height: box.height * imageSize.height
        )
    }
}
```

## 고급 패턴

### 1. 문서 스캔 (iOS 13+)

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

### 2. 이미지 유사도 비교

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
        
        return distance  // 낮을수록 유사
    } catch {
        return nil
    }
}
```

### 3. 실시간 물체 추적

```swift
class ObjectTracker {
    private var sequenceHandler = VNSequenceRequestHandler()
    private var trackingRequest: VNTrackObjectRequest?
    
    func startTracking(observation: VNDetectedObjectObservation) {
        trackingRequest = VNTrackObjectRequest(detectedObjectObservation: observation) { [weak self] request, error in
            guard let result = request.results?.first as? VNDetectedObjectObservation else { return }
            // 추적된 위치 업데이트
        }
        trackingRequest?.trackingLevel = .accurate
    }
    
    func track(in pixelBuffer: CVPixelBuffer) {
        guard let request = trackingRequest else { return }
        try? sequenceHandler.perform([request], on: pixelBuffer)
    }
}
```

## 주의사항

1. **좌표계 변환**
   - Vision: 좌하단 원점 (0,0), 정규화 좌표 (0~1)
   - UIKit: 좌상단 원점
   - `boundingBox`를 이미지 크기에 맞게 변환 필요

2. **비동기 처리**
   - 이미지 분석은 무거움 → 백그라운드에서 실행
   - UI 업데이트는 메인 스레드에서

3. **메모리 관리**
   - 큰 이미지는 리사이즈 후 처리
   - 연속 프레임 처리 시 `VNSequenceRequestHandler` 사용

4. **정확도 vs 속도**
   ```swift
   // 텍스트 인식
   request.recognitionLevel = .accurate  // 정확 (느림)
   request.recognitionLevel = .fast      // 빠름 (덜 정확)
   ```
