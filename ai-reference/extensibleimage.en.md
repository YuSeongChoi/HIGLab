# ExtensibleImage AI Reference

> Extensible image processing guide. Read this document to generate ExtensibleImage code.

## Overview

ExtensibleImage is an image extension framework available in iOS 18+.
Apps can provide custom image editing features to the system Photos app and other apps.
It's a modern replacement for Photo Editing Extension, offering better performance and flexibility.

## Required Import

```swift
import ExtensibleImage
```

## Project Setup

### 1. Add Extension Target
File > New > Target > Extensible Image Extension

### 2. Info.plist (Extension)

```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionAttributes</key>
    <dict>
        <key>PHSupportedMediaTypes</key>
        <array>
            <string>Image</string>
        </array>
        <key>EIImageEditingCapabilities</key>
        <array>
            <string>filter</string>
            <string>adjustment</string>
            <string>effect</string>
        </array>
    </dict>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.extensible-image.editing</string>
    <key>NSExtensionPrincipalClass</key>
    <string>$(PRODUCT_MODULE_NAME).ImageEditingProvider</string>
</dict>
```

## Core Components

### 1. EIImageEditingProvider (Extension Provider)

```swift
import ExtensibleImage

class ImageEditingProvider: EIImageEditingProvider {
    override func viewController(
        for configuration: EIImageEditingConfiguration
    ) -> EIImageEditingViewController {
        return ImageEditorViewController(configuration: configuration)
    }
}
```

### 2. EIImageEditingViewController (Editing View Controller)

```swift
class ImageEditorViewController: EIImageEditingViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // Access original image
    var originalImage: UIImage? {
        configuration.inputImage
    }
    
    // Complete editing
    func finishEditing(with image: UIImage) {
        completeEditing(with: image)
    }
    
    // Cancel editing
    func cancelEditing() {
        cancelRequest()
    }
}
```

### 3. EIImageEditingConfiguration (Configuration)

```swift
// Editing configuration info
let config: EIImageEditingConfiguration

config.inputImage        // Input image
config.contentMode      // Content mode
config.adjustmentData   // Previous adjustment data (when re-editing)
```

## Complete Working Example

### Extension Implementation

```swift
// ImageEditingProvider.swift
import ExtensibleImage

class ImageEditingProvider: EIImageEditingProvider {
    override func viewController(
        for configuration: EIImageEditingConfiguration
    ) -> EIImageEditingViewController {
        return FilterEditorViewController(configuration: configuration)
    }
}

// FilterEditorViewController.swift
import SwiftUI
import ExtensibleImage
import CoreImage
import CoreImage.CIFilterBuiltins

class FilterEditorViewController: EIImageEditingViewController {
    private var hostingController: UIHostingController<FilterEditorView>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let editorView = FilterEditorView(
            originalImage: configuration.inputImage,
            onComplete: { [weak self] image in
                self?.completeEditing(with: image)
            },
            onCancel: { [weak self] in
                self?.cancelRequest()
            }
        )
        
        hostingController = UIHostingController(rootView: editorView)
        
        if let hostingView = hostingController?.view {
            addChild(hostingController!)
            view.addSubview(hostingView)
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                hostingView.topAnchor.constraint(equalTo: view.topAnchor),
                hostingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                hostingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                hostingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            
            hostingController?.didMove(toParent: self)
        }
    }
}

// FilterEditorView.swift
struct FilterEditorView: View {
    let originalImage: UIImage?
    let onComplete: (UIImage) -> Void
    let onCancel: () -> Void
    
    @State private var processedImage: UIImage?
    @State private var selectedFilter: FilterType = .none
    @State private var intensity: Double = 0.5
    @State private var isProcessing = false
    
    enum FilterType: String, CaseIterable {
        case none = "Original"
        case sepia = "Sepia"
        case noir = "Noir"
        case chrome = "Chrome"
        case fade = "Fade"
        case vignette = "Vignette"
        case bloom = "Bloom"
    }
    
    var displayImage: UIImage? {
        processedImage ?? originalImage
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Image preview
                GeometryReader { geometry in
                    if let image = displayImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .overlay {
                    if isProcessing {
                        Color.black.opacity(0.3)
                        ProgressView()
                            .tint(.white)
                    }
                }
                
                // Intensity slider
                if selectedFilter != .none {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Intensity")
                            Slider(value: $intensity, in: 0...1)
                            Text("\(Int(intensity * 100))%")
                                .frame(width: 50)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                    .background(.bar)
                }
                
                // Filter selection
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(FilterType.allCases, id: \.self) { filter in
                            FilterButton(
                                filter: filter,
                                isSelected: selectedFilter == filter
                            ) {
                                selectedFilter = filter
                            }
                        }
                    }
                    .padding()
                }
                .background(.bar)
            }
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        if let image = processedImage ?? originalImage {
                            onComplete(image)
                        }
                    }
                }
            }
            .onChange(of: selectedFilter) { _, _ in
                applyFilter()
            }
            .onChange(of: intensity) { _, _ in
                applyFilter()
            }
        }
    }
    
    func applyFilter() {
        guard let original = originalImage,
              let ciImage = CIImage(image: original) else { return }
        
        if selectedFilter == .none {
            processedImage = originalImage
            return
        }
        
        isProcessing = true
        
        Task.detached(priority: .userInitiated) {
            let output = await processFilter(ciImage, filter: selectedFilter, intensity: intensity)
            
            await MainActor.run {
                processedImage = output
                isProcessing = false
            }
        }
    }
    
    func processFilter(_ input: CIImage, filter: FilterType, intensity: Double) async -> UIImage? {
        let context = CIContext()
        var output: CIImage?
        
        switch filter {
        case .none:
            output = input
            
        case .sepia:
            let filter = CIFilter.sepiaTone()
            filter.inputImage = input
            filter.intensity = Float(intensity)
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
            
        case .vignette:
            let filter = CIFilter.vignette()
            filter.inputImage = input
            filter.intensity = Float(intensity * 2)
            filter.radius = 1.5
            output = filter.outputImage
            
        case .bloom:
            let filter = CIFilter.bloom()
            filter.inputImage = input
            filter.intensity = Float(intensity)
            filter.radius = 10
            output = filter.outputImage
        }
        
        guard let ciOutput = output,
              let cgImage = context.createCGImage(ciOutput, from: ciOutput.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}

// FilterButton.swift
struct FilterButton: View {
    let filter: FilterEditorView.FilterType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: iconFor(filter))
                            .foregroundStyle(isSelected ? .white : .primary)
                    }
                
                Text(filter.rawValue)
                    .font(.caption)
                    .foregroundStyle(isSelected ? .blue : .primary)
            }
        }
    }
    
    func iconFor(_ filter: FilterEditorView.FilterType) -> String {
        switch filter {
        case .none: return "photo"
        case .sepia: return "camera.filters"
        case .noir: return "circle.lefthalf.filled"
        case .chrome: return "sparkles"
        case .fade: return "sun.haze"
        case .vignette: return "circle.dashed"
        case .bloom: return "light.max"
        }
    }
}
```

### Calling Extension from Host App

```swift
import SwiftUI
import PhotosUI
import ExtensibleImage

struct ImageEditingHostView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showingEditor = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding()
                    
                    Button("Edit") {
                        showingEditor = true
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    ContentUnavailableView(
                        "Select Image",
                        systemImage: "photo.badge.plus"
                    )
                }
            }
            .navigationTitle("Image Editing")
            .toolbar {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Image(systemName: "photo.badge.plus")
                }
            }
            .onChange(of: selectedItem) { _, item in
                Task {
                    if let data = try? await item?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                    }
                }
            }
            .sheet(isPresented: $showingEditor) {
                if let image = selectedImage {
                    ExtensibleImageEditor(
                        image: image,
                        onComplete: { editedImage in
                            selectedImage = editedImage
                            showingEditor = false
                        },
                        onCancel: {
                            showingEditor = false
                        }
                    )
                }
            }
        }
    }
}

// ExtensibleImageEditor wrapper
struct ExtensibleImageEditor: UIViewControllerRepresentable {
    let image: UIImage
    let onComplete: (UIImage) -> Void
    let onCancel: () -> Void
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let config = EIImageEditingConfiguration(inputImage: image)
        let editor = FilterEditorViewController(configuration: config)
        
        // Set custom complete/cancel handlers
        context.coordinator.onComplete = onComplete
        context.coordinator.onCancel = onCancel
        
        return UINavigationController(rootViewController: editor)
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var onComplete: ((UIImage) -> Void)?
        var onCancel: (() -> Void)?
    }
}
```

## Advanced Patterns

### 1. Saving/Restoring Adjustment Data

```swift
struct FilterAdjustment: Codable {
    var filterType: String
    var intensity: Double
    var timestamp: Date
}

extension FilterEditorViewController {
    func saveAdjustmentData() -> Data? {
        let adjustment = FilterAdjustment(
            filterType: selectedFilter.rawValue,
            intensity: intensity,
            timestamp: Date()
        )
        return try? JSONEncoder().encode(adjustment)
    }
    
    func loadAdjustmentData() {
        guard let data = configuration.adjustmentData,
              let adjustment = try? JSONDecoder().decode(FilterAdjustment.self, from: data) else {
            return
        }
        
        selectedFilter = FilterType(rawValue: adjustment.filterType) ?? .none
        intensity = adjustment.intensity
    }
    
    override func completeEditing(with image: UIImage) {
        // Save with adjustment data
        let adjustmentData = saveAdjustmentData()
        completeEditing(with: image, adjustmentData: adjustmentData)
    }
}
```

### 2. Live Photo Support

```swift
extension ImageEditingProvider {
    override func supportedMediaTypes() -> EIMediaTypes {
        return [.image, .livePhoto]
    }
}

class LivePhotoEditorViewController: EIImageEditingViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let livePhoto = configuration.inputLivePhoto {
            // Process Live Photo
            processLivePhoto(livePhoto)
        } else if let image = configuration.inputImage {
            // Process regular image
            processImage(image)
        }
    }
}
```

### 3. Batch Editing

```swift
struct BatchEditingView: View {
    @State private var images: [UIImage] = []
    @State private var processedImages: [UIImage] = []
    @State private var selectedFilter: FilterType = .sepia
    @State private var isProcessing = false
    
    var body: some View {
        VStack {
            // Image grid
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                ForEach(processedImages.indices, id: \.self) { index in
                    Image(uiImage: processedImages[index])
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipped()
                }
            }
            
            // Apply to all button
            Button("Apply Filter to All Images") {
                applyFilterToAll()
            }
            .disabled(isProcessing)
        }
    }
    
    func applyFilterToAll() {
        isProcessing = true
        
        Task {
            var results: [UIImage] = []
            
            for image in images {
                if let processed = await applyFilter(to: image, filter: selectedFilter) {
                    results.append(processed)
                }
            }
            
            await MainActor.run {
                processedImages = results
                isProcessing = false
            }
        }
    }
}
```

## Important Notes

1. **iOS Version**
   - ExtensibleImage: Requires iOS 18+
   - Use Photo Editing Extension for earlier versions

2. **Extension Limitations**
   - Memory limits apply
   - Be careful when processing large images

3. **Performance Optimization**
   - Process images on background threads
   - Use scaled-down images for previews

4. **Adjustment Data**
   - Save adjustment data for non-destructive editing
   - Preserve original when re-editing

5. **Simulator**
   - Extension testing is available
   - Photos app integration requires a real device
