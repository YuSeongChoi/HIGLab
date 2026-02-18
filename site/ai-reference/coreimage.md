# Core Image AI Reference

> 이미지 필터링 및 처리 가이드. 이 문서를 읽고 Core Image 코드를 생성할 수 있습니다.

## 개요

Core Image는 GPU 가속 이미지 필터링 프레임워크로, 200개 이상의 내장 필터를 제공합니다.
실시간 이미지/비디오 처리, 얼굴 감지, QR 코드 인식 등을 지원합니다.

## 필수 Import

```swift
import CoreImage
import CoreImage.CIFilterBuiltins  // 타입 안전한 필터 API
```

## 핵심 구성요소

### 1. CIImage (입력/출력)

```swift
// UIImage에서 생성
let ciImage = CIImage(image: uiImage)

// CGImage에서 생성
let ciImage = CIImage(cgImage: cgImage)

// Data에서 생성
let ciImage = CIImage(data: imageData)

// URL에서 생성
let ciImage = CIImage(contentsOf: url)
```

### 2. CIFilter (필터)

```swift
// 타입 안전한 API (권장)
let filter = CIFilter.sepiaTone()
filter.inputImage = ciImage
filter.intensity = 0.8
let output = filter.outputImage

// 문자열 기반 API (레거시)
let filter = CIFilter(name: "CISepiaTone")!
filter.setValue(ciImage, forKey: kCIInputImageKey)
filter.setValue(0.8, forKey: kCIInputIntensityKey)
let output = filter.outputImage
```

### 3. CIContext (렌더링)

```swift
// 기본 컨텍스트
let context = CIContext()

// Metal 가속 (성능 최적화)
let context = CIContext(mtlDevice: MTLCreateSystemDefaultDevice()!)

// CGImage로 렌더링
let cgImage = context.createCGImage(ciImage, from: ciImage.extent)

// UIImage로 변환
let uiImage = UIImage(cgImage: cgImage!)
```

## 전체 작동 예제

```swift
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI

// MARK: - Filter Type
enum ImageFilter: String, CaseIterable {
    case original = "원본"
    case sepia = "세피아"
    case noir = "흑백 누아르"
    case chrome = "크롬"
    case fade = "페이드"
    case instant = "인스턴트"
    case mono = "모노"
    case vignette = "비네트"
    case bloom = "블룸"
    case sharpen = "샤픈"
}

// MARK: - Image Processor
@Observable
class ImageProcessor {
    var originalImage: UIImage?
    var filteredImage: UIImage?
    var currentFilter: ImageFilter = .original
    var intensity: Float = 0.5
    var isProcessing = false
    
    private let context = CIContext(options: [.useSoftwareRenderer: false])
    
    func applyFilter() {
        guard let original = originalImage,
              let ciImage = CIImage(image: original) else { return }
        
        isProcessing = true
        
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return }
            
            let output = await self.processImage(ciImage, filter: self.currentFilter)
            
            await MainActor.run {
                self.filteredImage = output
                self.isProcessing = false
            }
        }
    }
    
    private func processImage(_ input: CIImage, filter: ImageFilter) async -> UIImage? {
        let output: CIImage?
        
        switch filter {
        case .original:
            output = input
            
        case .sepia:
            let filter = CIFilter.sepiaTone()
            filter.inputImage = input
            filter.intensity = intensity
            output = filter.outputImage
            
        case .noir:
            let filter = CIFilter.photoEffectNoir()
            filter.inputImage = input
            output = filter.outputImage
            
        case .chrome:
            let filter = CIFilter.photoEffectChrome()
            filter.inputImage = input
            output = filter.outputImage
            
        case .fade:
            let filter = CIFilter.photoEffectFade()
            filter.inputImage = input
            output = filter.outputImage
            
        case .instant:
            let filter = CIFilter.photoEffectInstant()
            filter.inputImage = input
            output = filter.outputImage
            
        case .mono:
            let filter = CIFilter.photoEffectMono()
            filter.inputImage = input
            output = filter.outputImage
            
        case .vignette:
            let filter = CIFilter.vignette()
            filter.inputImage = input
            filter.intensity = intensity * 2
            filter.radius = 1.5
            output = filter.outputImage
            
        case .bloom:
            let filter = CIFilter.bloom()
            filter.inputImage = input
            filter.intensity = intensity
            filter.radius = 10
            output = filter.outputImage
            
        case .sharpen:
            let filter = CIFilter.sharpenLuminance()
            filter.inputImage = input
            filter.sharpness = intensity
            output = filter.outputImage
        }
        
        guard let outputImage = output,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - Main View
struct ImageFilterView: View {
    @State private var processor = ImageProcessor()
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 이미지 표시
                ZStack {
                    if let image = processor.filteredImage ?? processor.originalImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    } else {
                        ContentUnavailableView(
                            "이미지 선택",
                            systemImage: "photo.badge.plus",
                            description: Text("사진을 선택하여 필터를 적용하세요")
                        )
                    }
                    
                    if processor.isProcessing {
                        ProgressView()
                            .scaleEffect(1.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.ultraThinMaterial)
                    }
                }
                .frame(maxHeight: .infinity)
                
                // 필터 컨트롤
                if processor.originalImage != nil {
                    VStack(spacing: 16) {
                        // 강도 조절
                        if processor.currentFilter != .original &&
                           [.sepia, .vignette, .bloom, .sharpen].contains(processor.currentFilter) {
                            HStack {
                                Text("강도")
                                Slider(value: $processor.intensity, in: 0...1)
                                    .onChange(of: processor.intensity) { _, _ in
                                        processor.applyFilter()
                                    }
                            }
                            .padding(.horizontal)
                        }
                        
                        // 필터 선택
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(ImageFilter.allCases, id: \.self) { filter in
                                    FilterButton(
                                        filter: filter,
                                        isSelected: processor.currentFilter == filter
                                    ) {
                                        processor.currentFilter = filter
                                        processor.applyFilter()
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                    .background(.ultraThinMaterial)
                }
            }
            .navigationTitle("이미지 필터")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Image(systemName: "photo.badge.plus")
                    }
                }
                
                if processor.filteredImage != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        ShareLink(item: Image(uiImage: processor.filteredImage!), preview: SharePreview("필터 적용 이미지", image: Image(uiImage: processor.filteredImage!)))
                    }
                }
            }
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        processor.originalImage = image
                        processor.filteredImage = image
                        processor.currentFilter = .original
                    }
                }
            }
        }
    }
}

// MARK: - Filter Button
struct FilterButton: View {
    let filter: ImageFilter
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(filter.rawValue)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.2))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    ImageFilterView()
}
```

## 고급 패턴

### 1. 필터 체이닝

```swift
func applyMultipleFilters(to image: CIImage) -> CIImage? {
    // 밝기 조절
    let brightness = CIFilter.colorControls()
    brightness.inputImage = image
    brightness.brightness = 0.1
    
    guard let brightened = brightness.outputImage else { return nil }
    
    // 대비 조절
    let contrast = CIFilter.colorControls()
    contrast.inputImage = brightened
    contrast.contrast = 1.2
    
    guard let contrasted = contrast.outputImage else { return nil }
    
    // 비네트 추가
    let vignette = CIFilter.vignette()
    vignette.inputImage = contrasted
    vignette.intensity = 1.0
    vignette.radius = 2.0
    
    return vignette.outputImage
}
```

### 2. 얼굴 감지

```swift
func detectFaces(in image: CIImage) -> [CIFaceFeature] {
    let detector = CIDetector(
        ofType: CIDetectorTypeFace,
        context: nil,
        options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
    )!
    
    let features = detector.features(
        in: image,
        options: [CIDetectorSmile: true, CIDetectorEyeBlink: true]
    ) as? [CIFaceFeature] ?? []
    
    for face in features {
        print("얼굴 위치: \(face.bounds)")
        print("웃음 감지: \(face.hasSmile)")
        print("왼쪽 눈 감김: \(face.leftEyeClosed)")
        print("오른쪽 눈 감김: \(face.rightEyeClosed)")
    }
    
    return features
}
```

### 3. QR/바코드 감지

```swift
func detectQRCode(in image: CIImage) -> [String] {
    let detector = CIDetector(
        ofType: CIDetectorTypeQRCode,
        context: nil,
        options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
    )!
    
    let features = detector.features(in: image) as? [CIQRCodeFeature] ?? []
    
    return features.compactMap { $0.messageString }
}
```

### 4. 실시간 비디오 필터

```swift
import AVFoundation

class VideoFilterProcessor: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let context = CIContext()
    private let filter = CIFilter.sepiaTone()
    
    var onFrame: ((UIImage) -> Void)?
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        filter.inputImage = ciImage
        filter.intensity = 0.8
        
        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        
        let uiImage = UIImage(cgImage: cgImage)
        
        DispatchQueue.main.async {
            self.onFrame?(uiImage)
        }
    }
}
```

### 5. 커스텀 필터 (CIKernel)

```swift
// Metal Shading Language로 커스텀 필터 작성
let kernelSource = """
#include <CoreImage/CoreImage.h>

extern "C" float4 customEffect(coreimage::sampler src, float intensity) {
    float4 color = src.sample(src.coord());
    float gray = dot(color.rgb, float3(0.299, 0.587, 0.114));
    float3 result = mix(color.rgb, float3(gray), intensity);
    return float4(result, color.a);
}
"""

// 커스텀 필터 사용
func applyCustomFilter(to image: CIImage) -> CIImage? {
    guard let kernel = try? CIColorKernel(functionName: "customEffect", fromMetalLibraryData: metalLibData) else {
        return nil
    }
    
    return kernel.apply(
        extent: image.extent,
        arguments: [image, 0.5]
    )
}
```

## 주요 필터 목록

### 색상 조절
| 필터 | 설명 |
|------|------|
| `CIFilter.colorControls()` | 밝기, 대비, 채도 |
| `CIFilter.exposureAdjust()` | 노출 조절 |
| `CIFilter.gammaAdjust()` | 감마 조절 |
| `CIFilter.hueAdjust()` | 색조 조절 |
| `CIFilter.temperatureAndTint()` | 색온도 |

### 사진 효과
| 필터 | 설명 |
|------|------|
| `CIFilter.photoEffectChrome()` | 크롬 효과 |
| `CIFilter.photoEffectFade()` | 페이드 효과 |
| `CIFilter.photoEffectInstant()` | 인스턴트 카메라 |
| `CIFilter.photoEffectMono()` | 흑백 |
| `CIFilter.photoEffectNoir()` | 누아르 |

### 블러/샤픈
| 필터 | 설명 |
|------|------|
| `CIFilter.gaussianBlur()` | 가우시안 블러 |
| `CIFilter.boxBlur()` | 박스 블러 |
| `CIFilter.motionBlur()` | 모션 블러 |
| `CIFilter.sharpenLuminance()` | 샤프닝 |
| `CIFilter.unsharpMask()` | 언샤프 마스크 |

## 주의사항

1. **CIContext 재사용**
   ```swift
   // ❌ 매번 생성 (느림)
   func process() {
       let context = CIContext()
       // ...
   }
   
   // ✅ 인스턴스 변수로 재사용
   private let context = CIContext()
   ```

2. **백그라운드 처리**
   - 이미지 처리는 메인 스레드 차단
   - `Task.detached`로 백그라운드 실행

3. **메모리 관리**
   - CIImage는 lazy evaluation
   - 체인이 길면 중간에 렌더링 고려

4. **좌표계**
   - Core Image는 좌하단 원점
   - UIKit은 좌상단 원점
   - 변환 필요할 수 있음

5. **시뮬레이터 성능**
   - 실제 기기보다 훨씬 느림
   - 성능 테스트는 실기기에서
