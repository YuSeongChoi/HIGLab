# ExtensibleImage AI Reference

> 확장 가능한 이미지 처리 가이드. 이 문서를 읽고 ExtensibleImage 코드를 생성할 수 있습니다.

## 개요

ExtensibleImage는 iOS 18+에서 제공하는 이미지 확장 프레임워크입니다.
앱에서 시스템 사진 앱 및 다른 앱에 커스텀 이미지 편집 기능을 제공할 수 있습니다.
Photo Editing Extension의 현대적인 대체제로, 더 나은 성능과 유연성을 제공합니다.

## 필수 Import

```swift
import ExtensibleImage
```

## 프로젝트 설정

### 1. Extension Target 추가
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

## 핵심 구성요소

### 1. EIImageEditingProvider (확장 제공자)

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

### 2. EIImageEditingViewController (편집 뷰컨트롤러)

```swift
class ImageEditorViewController: EIImageEditingViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // 원본 이미지 접근
    var originalImage: UIImage? {
        configuration.inputImage
    }
    
    // 편집 완료
    func finishEditing(with image: UIImage) {
        completeEditing(with: image)
    }
    
    // 편집 취소
    func cancelEditing() {
        cancelRequest()
    }
}
```

### 3. EIImageEditingConfiguration (설정)

```swift
// 편집 설정 정보
let config: EIImageEditingConfiguration

config.inputImage        // 입력 이미지
config.contentMode      // 콘텐츠 모드
config.adjustmentData   // 이전 조정 데이터 (재편집 시)
```

## 전체 작동 예제

### Extension 구현

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
        case none = "원본"
        case sepia = "세피아"
        case noir = "누아르"
        case chrome = "크롬"
        case fade = "페이드"
        case vignette = "비네트"
        case bloom = "블룸"
    }
    
    var displayImage: UIImage? {
        processedImage ?? originalImage
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 이미지 미리보기
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
                
                // 강도 슬라이더
                if selectedFilter != .none {
                    VStack(spacing: 8) {
                        HStack {
                            Text("강도")
                            Slider(value: $intensity, in: 0...1)
                            Text("\(Int(intensity * 100))%")
                                .frame(width: 50)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                    .background(.bar)
                }
                
                // 필터 선택
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
            .navigationTitle("필터")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
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

### 호스트 앱에서 Extension 호출

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
                    
                    Button("편집") {
                        showingEditor = true
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    ContentUnavailableView(
                        "이미지 선택",
                        systemImage: "photo.badge.plus"
                    )
                }
            }
            .navigationTitle("이미지 편집")
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
        
        // 커스텀 완료/취소 핸들러 설정
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

## 고급 패턴

### 1. 조정 데이터 저장/복원

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
        // 조정 데이터와 함께 저장
        let adjustmentData = saveAdjustmentData()
        completeEditing(with: image, adjustmentData: adjustmentData)
    }
}
```

### 2. Live Photo 지원

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
            // Live Photo 처리
            processLivePhoto(livePhoto)
        } else if let image = configuration.inputImage {
            // 일반 이미지 처리
            processImage(image)
        }
    }
}
```

### 3. 배치 편집

```swift
struct BatchEditingView: View {
    @State private var images: [UIImage] = []
    @State private var processedImages: [UIImage] = []
    @State private var selectedFilter: FilterType = .sepia
    @State private var isProcessing = false
    
    var body: some View {
        VStack {
            // 이미지 그리드
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                ForEach(processedImages.indices, id: \.self) { index in
                    Image(uiImage: processedImages[index])
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipped()
                }
            }
            
            // 일괄 적용 버튼
            Button("모든 이미지에 필터 적용") {
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

## 주의사항

1. **iOS 버전**
   - ExtensibleImage: iOS 18+ 필요
   - 이전 버전은 Photo Editing Extension 사용

2. **Extension 제한**
   - 메모리 제한 있음
   - 대용량 이미지 처리 시 주의

3. **성능 최적화**
   - 이미지 처리는 백그라운드 스레드에서
   - 미리보기는 축소된 이미지 사용

4. **조정 데이터**
   - 비파괴 편집을 위해 조정 데이터 저장
   - 재편집 시 원본 유지

5. **시뮬레이터**
   - Extension 테스트 가능
   - 사진 앱 연동은 실기기 필요
