# PhotosUI AI Reference

> Photo library access guide. You can generate PhotosUI code by reading this document.

## Overview

PhotosUI provides UI for selecting images/videos from the user's photo library.
It supports iOS 16+ PHPickerViewController and SwiftUI's PhotosPicker.

## Required Import

```swift
import PhotosUI
import SwiftUI
```

## Project Setup (Optional)

```xml
<!-- Only needed for full library access -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Required to select photos from album.</string>

<!-- When write permission is needed -->
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Required to save photos to album.</string>
```

> **Note**: PhotosPicker can be used without permission (Limited Access)

## Core Components

### 1. PhotosPicker (SwiftUI, iOS 16+)

```swift
struct SimplePickerView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    var body: some View {
        VStack {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Text("Select Photo")
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

### 2. Multiple Selection

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
                Label("Select Photos (up to 5)", systemImage: "photo.on.rectangle.angled")
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

### 3. Filter Options

```swift
// Images only
PhotosPicker(selection: $item, matching: .images)

// Videos only
PhotosPicker(selection: $item, matching: .videos)

// Live Photos
PhotosPicker(selection: $item, matching: .livePhotos)

// Screenshots only
PhotosPicker(selection: $item, matching: .screenshots)

// Combination
PhotosPicker(selection: $item, matching: .any(of: [.images, .videos]))

// Exclusion
PhotosPicker(selection: $item, matching: .not(.videos))
```

## Complete Working Example

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
        // Method 1: Load as Data
        if let data = try? await item.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            return image
        }
        
        // Method 2: Load directly as Image (iOS 16+)
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
                    // Add photos button
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
                                Text("Add Photos")
                                    .font(.caption)
                            }
                        }
                        .aspectRatio(1, contentMode: .fill)
                    }
                    
                    // Selected images
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
            .navigationTitle("Gallery")
            .overlay {
                if viewModel.isLoading {
                    ProgressView("Loading...")
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
                        Button("Close") { dismiss() }
                    }
                    
                    ToolbarItem(placement: .bottomBar) {
                        ShareLink(item: Image(uiImage: image), preview: SharePreview("Photo", image: Image(uiImage: image)))
                    }
                }
        }
    }
}
```

## Advanced Patterns

### 1. Custom Transferable Type

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

// Usage
if let profile = try? await item.loadTransferable(type: ProfileImage.self) {
    // Use profile.image, profile.metadata
}
```

### 2. Loading Live Photos

```swift
import Photos

func loadLivePhoto(from item: PhotosPickerItem) async -> PHLivePhoto? {
    try? await item.loadTransferable(type: PHLivePhoto.self)
}

// Display with LivePhotoView
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

### 3. Loading Videos

```swift
func loadVideo(from item: PhotosPickerItem) async -> URL? {
    // Load as Movie type
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

### 4. Full Photos Access (Legacy)

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

## Notes

1. **No Permission Required**
   - `PhotosPicker` works with Limited Access
   - Only selected photos are accessible
   - Permission only needed for full library access

2. **Async Loading**
   - `loadTransferable` is async
   - Large images take time
   - Show progress indicator

3. **Memory Management**
   - Be careful with high-resolution images
   - Resize as needed
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

4. **iOS Version**
   - `PhotosPicker`: iOS 16+
   - iOS 15: Use `PHPickerViewController`
