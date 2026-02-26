# Core Image AI Reference

> Image filtering and processing guide. Read this document to generate Core Image code.

## Overview

Core Image is a GPU-accelerated image filtering framework that provides over 200 built-in filters.
It supports real-time image/video processing, face detection, QR code recognition, and more.

## Required Imports

```swift
import CoreImage
import CoreImage.CIFilterBuiltins  // Type-safe filter API
```

## Core Components

### 1. CIImage (Input/Output)

```swift
// Create from UIImage
let ciImage = CIImage(image: uiImage)

// Create from CGImage
let ciImage = CIImage(cgImage: cgImage)

// Create from Data
let ciImage = CIImage(data: imageData)

// Create from URL
let ciImage = CIImage(contentsOf: url)
```

### 2. CIFilter (Filter)

```swift
// Type-safe API (recommended)
let filter = CIFilter.sepiaTone()
filter.inputImage = ciImage
filter.intensity = 0.8
let output = filter.outputImage

// String-based API (legacy)
let filter = CIFilter(name: "CISepiaTone")!
filter.setValue(ciImage, forKey: kCIInputImageKey)
filter.setValue(0.8, forKey: kCIInputIntensityKey)
let output = filter.outputImage
```

### 3. CIContext (Rendering)

```swift
// Default context
let context = CIContext()

// Metal accelerated (performance optimized)
let context = CIContext(mtlDevice: MTLCreateSystemDefaultDevice()!)

// Render to CGImage
let cgImage = context.createCGImage(ciImage, from: ciImage.extent)

// Convert to UIImage
let uiImage = UIImage(cgImage: cgImage!)
```

## Complete Working Example

```swift
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI

// MARK: - Filter Type
enum ImageFilter: String, CaseIterable {
    case original = "Original"
    case sepia = "Sepia"
    case noir = "Noir"
    case chrome = "Chrome"
    case fade = "Fade"
    case instant = "Instant"
    case mono = "Mono"
    case vignette = "Vignette"
    case bloom = "Bloom"
    case sharpen = "Sharpen"
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
                // Image display
                ZStack {
                    if let image = processor.filteredImage ?? processor.originalImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    } else {
                        ContentUnavailableView(
                            "Select Image",
                            systemImage: "photo.badge.plus",
                            description: Text("Select a photo to apply filters")
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
                
                // Filter controls
                if processor.originalImage != nil {
                    VStack(spacing: 16) {
                        // Intensity control
                        if processor.currentFilter != .original &&
                           [.sepia, .vignette, .bloom, .sharpen].contains(processor.currentFilter) {
                            HStack {
                                Text("Intensity")
                                Slider(value: $processor.intensity, in: 0...1)
                                    .onChange(of: processor.intensity) { _, _ in
                                        processor.applyFilter()
                                    }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Filter selection
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
            .navigationTitle("Image Filter")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Image(systemName: "photo.badge.plus")
                    }
                }
                
                if processor.filteredImage != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        ShareLink(item: Image(uiImage: processor.filteredImage!), preview: SharePreview("Filtered Image", image: Image(uiImage: processor.filteredImage!)))
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

## Advanced Patterns

### 1. Filter Chaining

```swift
func applyMultipleFilters(to image: CIImage) -> CIImage? {
    // Brightness adjustment
    let brightness = CIFilter.colorControls()
    brightness.inputImage = image
    brightness.brightness = 0.1
    
    guard let brightened = brightness.outputImage else { return nil }
    
    // Contrast adjustment
    let contrast = CIFilter.colorControls()
    contrast.inputImage = brightened
    contrast.contrast = 1.2
    
    guard let contrasted = contrast.outputImage else { return nil }
    
    // Add vignette
    let vignette = CIFilter.vignette()
    vignette.inputImage = contrasted
    vignette.intensity = 1.0
    vignette.radius = 2.0
    
    return vignette.outputImage
}
```

### 2. Face Detection

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
        print("Face position: \(face.bounds)")
        print("Smile detected: \(face.hasSmile)")
        print("Left eye closed: \(face.leftEyeClosed)")
        print("Right eye closed: \(face.rightEyeClosed)")
    }
    
    return features
}
```

### 3. QR/Barcode Detection

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

### 4. Real-time Video Filter

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

### 5. Custom Filter (CIKernel)

```swift
// Write custom filter with Metal Shading Language
let kernelSource = """
#include <CoreImage/CoreImage.h>

extern "C" float4 customEffect(coreimage::sampler src, float intensity) {
    float4 color = src.sample(src.coord());
    float gray = dot(color.rgb, float3(0.299, 0.587, 0.114));
    float3 result = mix(color.rgb, float3(gray), intensity);
    return float4(result, color.a);
}
"""

// Use custom filter
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

## Common Filter List

### Color Adjustments
| Filter | Description |
|------|------|
| `CIFilter.colorControls()` | Brightness, contrast, saturation |
| `CIFilter.exposureAdjust()` | Exposure adjustment |
| `CIFilter.gammaAdjust()` | Gamma adjustment |
| `CIFilter.hueAdjust()` | Hue adjustment |
| `CIFilter.temperatureAndTint()` | Color temperature |

### Photo Effects
| Filter | Description |
|------|------|
| `CIFilter.photoEffectChrome()` | Chrome effect |
| `CIFilter.photoEffectFade()` | Fade effect |
| `CIFilter.photoEffectInstant()` | Instant camera |
| `CIFilter.photoEffectMono()` | Black and white |
| `CIFilter.photoEffectNoir()` | Noir |

### Blur/Sharpen
| Filter | Description |
|------|------|
| `CIFilter.gaussianBlur()` | Gaussian blur |
| `CIFilter.boxBlur()` | Box blur |
| `CIFilter.motionBlur()` | Motion blur |
| `CIFilter.sharpenLuminance()` | Sharpening |
| `CIFilter.unsharpMask()` | Unsharp mask |

## Important Notes

1. **Reuse CIContext**
   ```swift
   // ❌ Creating every time (slow)
   func process() {
       let context = CIContext()
       // ...
   }
   
   // ✅ Reuse as instance variable
   private let context = CIContext()
   ```

2. **Background Processing**
   - Image processing blocks main thread
   - Use `Task.detached` for background execution

3. **Memory Management**
   - CIImage uses lazy evaluation
   - Consider intermediate rendering for long chains

4. **Coordinate System**
   - Core Image uses bottom-left origin
   - UIKit uses top-left origin
   - Conversion may be needed

5. **Simulator Performance**
   - Much slower than real device
   - Performance testing should be done on device
