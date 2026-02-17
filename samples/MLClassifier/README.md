# MLClassifier

CoreML과 Vision 프레임워크를 사용한 이미지 분류 샘플 앱입니다.

## 개요

이 프로젝트는 Apple의 CoreML과 Vision 프레임워크를 활용하여 이미지 분류를 수행하는 방법을 보여줍니다.

### 주요 기능

- 📷 **사진 분류**: 사진 라이브러리에서 이미지를 선택하여 분류
- 🎥 **실시간 카메라 분류**: 카메라 피드를 실시간으로 분류
- 🧠 **다중 모델 지원**: MobileNetV2, ResNet50, SqueezeNet 모델 선택 가능
- 📊 **신뢰도 시각화**: 분류 결과의 신뢰도를 프로그레스 바로 표시

## 프로젝트 구조

```
MLClassifier/
├── Shared/                     # 공유 코드
│   ├── ClassificationResult.swift  # 분류 결과 모델
│   ├── MLModelManager.swift        # ML 모델 관리
│   └── ImageClassifier.swift       # Vision + CoreML 분류기
│
├── MLClassifierApp/            # 앱 코드
│   ├── MLClassifierApp.swift       # @main 앱 진입점
│   ├── ContentView.swift           # 메인 뷰 (탭 뷰)
│   ├── PhotoClassifyView.swift     # 사진 분류 뷰
│   ├── CameraClassifyView.swift    # 실시간 카메라 분류 뷰
│   └── ResultsView.swift           # 결과 표시 컴포넌트
│
└── README.md
```

## 핵심 기술

### VNCoreMLRequest

Vision 프레임워크의 `VNCoreMLRequest`를 사용하여 CoreML 모델로 이미지 분류를 수행합니다:

```swift
// Vision 모델 생성
let visionModel = try VNCoreMLModel(for: mlModel)

// 분류 요청 생성
let request = VNCoreMLRequest(model: visionModel) { request, error in
    guard let observations = request.results as? [VNClassificationObservation] else {
        return
    }
    
    // 결과 처리
    let results = observations.map { observation in
        ClassificationResult(
            label: observation.identifier,
            confidence: observation.confidence
        )
    }
}

// 이미지 핸들러로 요청 실행
let handler = VNImageRequestHandler(cgImage: cgImage)
try handler.perform([request])
```

### 실시간 카메라 분류

`AVCaptureVideoDataOutput`을 사용하여 카메라 프레임을 캡처하고, 각 프레임에 대해 분류를 수행합니다:

```swift
// 프레임 캡처 델리게이트
func captureOutput(_ output: AVCaptureOutput,
                   didOutput sampleBuffer: CMSampleBuffer,
                   from connection: AVCaptureConnection) {
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
    let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
    
    // 분류 수행
    Task {
        try await classifier.classify(ciImage: ciImage)
    }
}
```

## ML 모델 추가

이 앱은 Apple에서 제공하는 사전 학습된 모델을 사용합니다:

1. [Apple ML Models](https://developer.apple.com/machine-learning/models/)에서 모델 다운로드
2. `.mlmodel` 파일을 Xcode 프로젝트에 추가
3. Xcode가 자동으로 `.mlmodelc`로 컴파일

### 지원 모델

| 모델 | 설명 | 크기 |
|-----|-----|-----|
| MobileNetV2 | 모바일 최적화, 빠른 추론 | ~14MB |
| ResNet50 | 높은 정확도 | ~98MB |
| SqueezeNet | 경량화 모델 | ~5MB |

## 필요 권한

앱이 정상적으로 동작하려면 다음 권한이 필요합니다:

### Info.plist

```xml
<!-- 사진 라이브러리 접근 -->
<key>NSPhotoLibraryUsageDescription</key>
<string>사진을 선택하여 이미지 분류를 수행합니다.</string>

<!-- 카메라 접근 -->
<key>NSCameraUsageDescription</key>
<string>실시간 이미지 분류를 위해 카메라에 접근합니다.</string>
```

## 플랫폼 지원

- iOS 17.0+
- macOS 14.0+ (카메라 기능 제한적)

## 참고 자료

- [Vision Framework](https://developer.apple.com/documentation/vision)
- [Core ML](https://developer.apple.com/documentation/coreml)
- [VNCoreMLRequest](https://developer.apple.com/documentation/vision/vncoremlrequest)
- [Classifying Images with Vision and Core ML](https://developer.apple.com/documentation/vision/classifying_images_with_vision_and_core_ml)
