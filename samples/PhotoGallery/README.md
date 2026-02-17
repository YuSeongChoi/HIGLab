# PhotoGallery

PhotosUI의 `PhotosPicker`를 사용한 사진/비디오 갤러리 샘플 앱입니다.

## 주요 기능

- **PhotosPicker**: iOS 16+ 의 모던 사진 피커 사용
- **Transferable**: Swift의 Transferable 프로토콜로 미디어 로딩
- **이미지 캐시**: NSCache 기반 메모리 캐시
- **비디오 재생**: AVPlayer를 활용한 커스텀 비디오 플레이어
- **제스처 지원**: 핀치 줌, 스와이프 네비게이션

## 프로젝트 구조

```
PhotoGallery/
├── Shared/
│   ├── MediaItem.swift      # 미디어 아이템 모델
│   ├── PhotoLoader.swift    # Transferable 기반 미디어 로더
│   └── ImageCache.swift     # 이미지 캐시 관리
│
├── PhotoGalleryApp/
│   ├── PhotoGalleryApp.swift   # 앱 진입점
│   ├── ContentView.swift       # 메인 뷰 (PhotosPicker 포함)
│   ├── GalleryGridView.swift   # 그리드 레이아웃
│   ├── PhotoDetailView.swift   # 상세 보기 (전체 화면)
│   └── VideoPlayerView.swift   # 비디오 플레이어
│
└── README.md
```

## 핵심 구현

### PhotosPicker 사용

```swift
PhotosPicker(
    selection: $selectedItems,
    maxSelectionCount: 20,
    matching: .any(of: [.images, .videos]),
    photoLibrary: .shared()
) {
    Text("사진 선택하기")
}
```

### Transferable 프로토콜

이미지와 비디오를 안전하게 로드하기 위해 `Transferable` 프로토콜을 구현합니다:

```swift
struct TransferableImage: Transferable {
    let image: Image
    let uiImage: UIImage
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let uiImage = UIImage(data: data) else {
                throw PhotoLoaderError.invalidImageData
            }
            return TransferableImage(image: Image(uiImage: uiImage), uiImage: uiImage)
        }
    }
}
```

### 이미지 캐시

메모리 기반 캐시로 이미지 재로딩을 방지합니다:

```swift
// 캐시에서 조회
if let cached = ImageCache.shared.image(forKey: item.cacheKey) {
    return Image(uiImage: cached)
}

// 캐시에 저장
ImageCache.shared.setImage(uiImage, forKey: item.cacheKey)
```

## 요구 사항

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## HIG 참고

- [Photos Picker](https://developer.apple.com/design/human-interface-guidelines/photos-picker)
- [Image views](https://developer.apple.com/design/human-interface-guidelines/image-views)
- [Video](https://developer.apple.com/design/human-interface-guidelines/playing-video)

## 권한

이 앱은 PhotosPicker를 사용하므로 별도의 권한 요청이 필요 없습니다.  
PhotosPicker는 시스템이 관리하는 out-of-process UI로, 사용자가 선택한 항목만 앱에 전달됩니다.

## 라이선스

MIT License
