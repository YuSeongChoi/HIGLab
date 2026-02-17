# VisionScanner

Apple Vision 프레임워크를 활용한 이미지 분석 샘플 앱입니다.

## 주요 기능

### 📝 텍스트 인식 (OCR)
- 이미지에서 텍스트를 추출합니다
- 한국어, 영어, 일본어 지원
- 정확도 모드 선택 가능 (정확 / 빠름)
- 인식된 텍스트 복사 기능

### 📊 바코드 스캔
- 다양한 바코드 형식 지원
  - QR 코드
  - EAN-13 / EAN-8
  - Code 128 / Code 39
  - UPC-E
  - Aztec / PDF417 / Data Matrix
- URL 자동 감지 및 열기 기능

### 😊 얼굴 인식
- 이미지에서 얼굴 영역 감지
- 얼굴 랜드마크 검출 (눈, 코, 입, 눈썹)
- 얼굴 방향 분석 (회전 각도)
- 다중 얼굴 동시 인식

## 프로젝트 구조

```
VisionScanner/
├── Shared/
│   ├── ScanResult.swift      # 스캔 결과 모델 (텍스트/바코드/얼굴)
│   ├── VisionManager.swift   # Vision 프레임워크 래퍼
│   └── ImageProcessor.swift  # 이미지 전처리 유틸리티
│
├── VisionScannerApp/
│   ├── VisionScannerApp.swift      # @main 앱 엔트리 포인트
│   ├── ContentView.swift           # 메인 화면 (기능 선택)
│   ├── TextRecognitionView.swift   # OCR 화면
│   ├── BarcodeView.swift           # 바코드 스캔 화면
│   └── FaceDetectionView.swift     # 얼굴 인식 화면
│
└── README.md
```

## 핵심 컴포넌트

### VisionManager
Vision 프레임워크의 다양한 요청을 래핑합니다:

```swift
// 텍스트 인식
let results = await visionManager.recognizeText(
    in: image,
    recognitionLevel: .accurate,
    languages: ["ko-KR", "en-US"]
)

// 바코드 스캔
let barcodes = await visionManager.scanBarcodes(
    in: image,
    symbologies: [.qr, .ean13, .code128]
)

// 얼굴 인식
let faces = await visionManager.detectFaces(
    in: image,
    detectLandmarks: true
)
```

### ImageProcessor
이미지 전처리 기능을 제공합니다:

```swift
// OCR용 전처리 (방향 보정, 리사이즈, 대비 향상)
let processed = ImageProcessor.preprocessForOCR(image)

// 바코드용 전처리
let processed = ImageProcessor.preprocessForBarcode(image)

// 얼굴 인식용 전처리
let processed = ImageProcessor.preprocessForFaceDetection(image)

// 개별 처리
let resized = ImageProcessor.resize(image, maxDimension: 2048)
let grayscale = ImageProcessor.convertToGrayscale(image)
let enhanced = ImageProcessor.enhanceContrast(image, contrast: 1.3)
```

### 좌표 변환
Vision의 정규화된 좌표를 뷰 좌표로 변환합니다:

```swift
// Vision 좌표계: 좌하단 원점 (0,0)
// SwiftUI 좌표계: 좌상단 원점 (0,0)
let viewRect = VisionManager.convertBoundingBox(
    result.boundingBox,
    to: viewSize
)
```

## Vision 프레임워크 요청 종류

| 요청 | 설명 | iOS |
|------|------|-----|
| `VNRecognizeTextRequest` | 텍스트 인식 (OCR) | 13+ |
| `VNDetectBarcodesRequest` | 바코드/QR 인식 | 11+ |
| `VNDetectFaceRectanglesRequest` | 얼굴 영역 감지 | 11+ |
| `VNDetectFaceLandmarksRequest` | 얼굴 랜드마크 검출 | 11+ |

## 요구사항

- iOS 17.0+
- Xcode 16.0+
- Swift 6.0

## 권한

### Info.plist
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>이미지를 분석하기 위해 사진 라이브러리 접근이 필요합니다.</string>
```

## 참고 자료

- [Vision Framework](https://developer.apple.com/documentation/vision)
- [Recognizing Text in Images](https://developer.apple.com/documentation/vision/recognizing-text-in-images)
- [Detecting Barcodes in Images](https://developer.apple.com/documentation/vision/vndetectbarcodesrequest)
- [Detecting Faces in Images](https://developer.apple.com/documentation/vision/detecting-faces-in-images)

## 라이선스

HIG Lab 샘플 프로젝트
