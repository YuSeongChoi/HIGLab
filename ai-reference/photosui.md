# PhotosUI AI Reference

> 사진 라이브러리 접근 가이드. 이 문서를 읽고 PhotosUI 코드를 생성할 수 있습니다.

## 개요

PhotosUI는 사용자의 사진 라이브러리에서 이미지/비디오를 선택하는 UI를 제공합니다.
iOS 16+ PHPickerViewController, SwiftUI의 PhotosPicker를 지원합니다.

## 필수 Import

```swift
import PhotosUI
import SwiftUI
```

## 프로젝트 설정 (선택적)

```xml
<!-- 전체 라이브러리 접근 시만 필요 -->
<key>NSPhotoLibraryUsageDescription</key>
<string>앨범에서 사진을 선택하기 위해 필요합니다.</string>

<!-- 쓰기 권한 필요 시 -->
<key>NSPhotoLibraryAddUsageDescription</key>
<string>사진을 앨범에 저장하기 위해 필요합니다.</string>
```

> **참고**: PhotosPicker는 권한 없이 사용 가능 (Limited Access)

## 핵심 구성요소

### 1. PhotosPicker (SwiftUI, iOS 16+)

```swift
struct SimplePickerView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    var body: some View {
        VStack {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Text("사진 선택")
            }
            
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                }
            }
        }
    }
}
```

### 2. 다중 선택

```swift
struct MultiplePickerView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    
    var body: some View {
        VStack {
            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 5,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Label("사진 선택 (최대 5장)", systemImage: "photo.on.rectangle.angled")
            }
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(selectedImages, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .onChange(of: selectedItems) { _, newItems in
            Task {
                selectedImages = []
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImages.append(image)
                    }
                }
            }
        }
    }
}
```

### 3. 필터 옵션

```swift
// 이미지만
PhotosPicker(selection: $item, matching: .images)

// 비디오만
PhotosPicker(selection: $item, matching: .videos)

// Live Photo
PhotosPicker(selection: $item, matching: .livePhotos)

// 스크린샷만
PhotosPicker(selection: $item, matching: .screenshots)

// 조합
PhotosPicker(selection: $item, matching: .any(of: [.images, .videos]))

// 제외
PhotosPicker(selection: $item, matching: .not(.videos))
```

## 전체 작동 예제

```swift
import SwiftUI
import PhotosUI

// MARK: - View Model
@Observable
class PhotoGalleryViewModel {
    var selectedItems: [PhotosPickerItem] = []
    var images: [IdentifiableImage] = []
    var isLoading = false
    
    @MainActor
    func loadImages() async {
        isLoading = true
        defer { isLoading = false }
        
        images = []
        
        for item in selectedItems {
            if let image = await loadImage(from: item) {
                images.append(IdentifiableImage(image: image))
            }
        }
    }
    
    private func loadImage(from item: PhotosPickerItem) async -> UIImage? {
        // 방법 1: Data로 로드
        if let data = try? await item.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            return image
        }
        
        // 방법 2: Image로 직접 로드 (iOS 16+)
        // if let image = try? await item.loadTransferable(type: Image.self) { ... }
        
        return nil
    }
}

struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

// MARK: - Views
struct PhotoGalleryView: View {
    @State private var viewModel = PhotoGalleryViewModel()
    @State private var selectedImage: IdentifiableImage?
    
    let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 2)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 2) {
                    // 사진 추가 버튼
                    PhotosPicker(
                        selection: $viewModel.selectedItems,
                        maxSelectionCount: 20,
                        matching: .images
                    ) {
                        ZStack {
                            Color.gray.opacity(0.2)
                            VStack {
                                Image(systemName: "plus")
                                    .font(.largeTitle)
                                Text("사진 추가")
                                    .font(.caption)
                            }
                        }
                        .aspectRatio(1, contentMode: .fill)
                    }
                    
                    // 선택된 이미지들
                    ForEach(viewModel.images) { item in
                        Image(uiImage: item.image)
                            .resizable()
                            .scaledToFill()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fill)
                            .clipped()
                            .onTapGesture {
                                selectedImage = item
                            }
                    }
                }
            }
            .navigationTitle("갤러리")
            .overlay {
                if viewModel.isLoading {
                    ProgressView("로딩 중...")
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .onChange(of: viewModel.selectedItems) { _, _ in
                Task {
                    await viewModel.loadImages()
                }
            }
            .fullScreenCover(item: $selectedImage) { item in
                ImageDetailView(image: item.image)
            }
        }
    }
}

struct ImageDetailView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("닫기") { dismiss() }
                    }
                    
                    ToolbarItem(placement: .bottomBar) {
                        ShareLink(item: Image(uiImage: image), preview: SharePreview("사진", image: Image(uiImage: image)))
                    }
                }
        }
    }
}
```

## 고급 패턴

### 1. Transferable 커스텀 타입

```swift
struct ProfileImage: Transferable {
    let image: UIImage
    let metadata: ImageMetadata
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let image = UIImage(data: data) else {
                throw TransferError.importFailed
            }
            return ProfileImage(image: image, metadata: ImageMetadata())
        }
    }
}

// 사용
if let profile = try? await item.loadTransferable(type: ProfileImage.self) {
    // profile.image, profile.metadata 사용
}
```

### 2. Live Photo 로드

```swift
import Photos

func loadLivePhoto(from item: PhotosPickerItem) async -> PHLivePhoto? {
    try? await item.loadTransferable(type: PHLivePhoto.self)
}

// LivePhotoView로 표시
struct LivePhotoViewContainer: UIViewRepresentable {
    let livePhoto: PHLivePhoto
    
    func makeUIView(context: Context) -> PHLivePhotoView {
        let view = PHLivePhotoView()
        view.livePhoto = livePhoto
        view.contentMode = .scaleAspectFit
        return view
    }
    
    func updateUIView(_ uiView: PHLivePhotoView, context: Context) {
        uiView.livePhoto = livePhoto
    }
}
```

### 3. 비디오 로드

```swift
func loadVideo(from item: PhotosPickerItem) async -> URL? {
    // Movie 타입으로 로드
    if let movie = try? await item.loadTransferable(type: Movie.self) {
        return movie.url
    }
    return nil
}

struct Movie: Transferable {
    let url: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.url)
        } importing: { received in
            let destination = FileManager.default.temporaryDirectory.appendingPathComponent(received.file.lastPathComponent)
            try FileManager.default.copyItem(at: received.file, to: destination)
            return Movie(url: destination)
        }
    }
}
```

### 4. 전체 Photos 접근 (레거시)

```swift
import Photos

func requestFullAccess() async -> PHAuthorizationStatus {
    await PHPhotoLibrary.requestAuthorization(for: .readWrite)
}

func fetchAllPhotos() -> PHFetchResult<PHAsset> {
    let options = PHFetchOptions()
    options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
    
    return PHAsset.fetchAssets(with: options)
}
```

## 주의사항

1. **권한 없이 사용 가능**
   - `PhotosPicker`는 Limited Access로 동작
   - 사용자가 선택한 사진만 접근 가능
   - 전체 라이브러리 접근 시에만 권한 필요

2. **비동기 로딩**
   - `loadTransferable`은 async
   - 대용량 이미지는 시간 소요
   - Progress 표시 권장

3. **메모리 관리**
   - 고해상도 이미지 주의
   - 필요시 리사이즈하여 사용
   ```swift
   func resizedImage(_ image: UIImage, maxSize: CGFloat) -> UIImage {
       let ratio = min(maxSize / image.size.width, maxSize / image.size.height)
       let newSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
       
       UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
       image.draw(in: CGRect(origin: .zero, size: newSize))
       let resized = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()
       
       return resized ?? image
   }
   ```

4. **iOS 버전**
   - `PhotosPicker`: iOS 16+
   - iOS 15: `PHPickerViewController` 사용
