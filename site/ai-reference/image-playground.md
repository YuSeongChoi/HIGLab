# Image Playground AI Reference

> Apple Intelligence 이미지 생성 가이드. 이 문서를 읽고 Image Playground 코드를 생성할 수 있습니다.

## 개요

Image Playground는 Apple Intelligence의 이미지 생성 프레임워크입니다.
텍스트 프롬프트, 개념, 사람 등을 기반으로 세 가지 스타일(애니메이션, 일러스트, 스케치)의 이미지를 생성합니다.
iOS 18.1+, Apple Silicon 기기 필요.

## 필수 Import

```swift
import ImagePlayground
```

## 프로젝트 설정

- **iOS 18.1+** 필요
- **Apple Silicon** 기기만 지원 (A17 Pro 이상)
- 추가 권한 불필요

## 핵심 구성요소

### 1. ImagePlaygroundSheet (SwiftUI)

```swift
import SwiftUI
import ImagePlayground

struct ContentView: View {
    @State private var showPlayground = false
    @State private var generatedImage: URL?
    
    var body: some View {
        VStack {
            if let imageURL = generatedImage {
                AsyncImage(url: imageURL) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }
            }
            
            Button("이미지 생성") {
                showPlayground = true
            }
        }
        .imagePlaygroundSheet(
            isPresented: $showPlayground,
            concept: "우주에서 피자를 먹는 고양이"
        ) { url in
            generatedImage = url
        }
    }
}
```

### 2. Concept (입력 개념)

```swift
// 텍스트 개념
ImagePlaygroundConcept.text("해변의 일몰")

// 추출된 개념 (텍스트에서 핵심 개념 추출)
ImagePlaygroundConcept.extracted(from: "강아지가 공원에서 뛰어놀고 있다", title: "강아지")

// 사람 (PersonsNameComponents)
ImagePlaygroundConcept.person(url: photoURL, nameComponents: personName)
```

### 3. Style (이미지 스타일)

```swift
// 애니메이션 (3D 느낌)
ImagePlaygroundStyle.animation

// 일러스트 (플랫 디자인)
ImagePlaygroundStyle.illustration

// 스케치 (손그림 느낌)
ImagePlaygroundStyle.sketch
```

## 전체 작동 예제

```swift
import SwiftUI
import ImagePlayground

// MARK: - Main View
struct ImagePlaygroundView: View {
    @State private var showPlayground = false
    @State private var generatedImages: [URL] = []
    @State private var prompt = ""
    @State private var selectedStyle: ImagePlaygroundStyle = .animation
    @State private var isSupported = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 지원 여부 확인
                if !isSupported {
                    ContentUnavailableView(
                        "지원되지 않는 기기",
                        systemImage: "exclamationmark.triangle",
                        description: Text("Image Playground는 A17 Pro 이상의 Apple Silicon 기기에서만 사용 가능합니다.")
                    )
                } else {
                    // 생성된 이미지 그리드
                    if generatedImages.isEmpty {
                        ContentUnavailableView(
                            "생성된 이미지 없음",
                            systemImage: "photo.badge.plus",
                            description: Text("아래 버튼을 눌러 이미지를 생성하세요")
                        )
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 12) {
                                ForEach(generatedImages, id: \.self) { url in
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(height: 150)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    } placeholder: {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.quaternary)
                                            .frame(height: 150)
                                            .overlay { ProgressView() }
                                    }
                                    .contextMenu {
                                        Button {
                                            copyImage(from: url)
                                        } label: {
                                            Label("복사", systemImage: "doc.on.doc")
                                        }
                                        
                                        ShareLink(item: url)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                    
                    Spacer()
                    
                    // 프롬프트 입력
                    VStack(spacing: 12) {
                        TextField("무엇을 그릴까요?", text: $prompt)
                            .textFieldStyle(.roundedBorder)
                        
                        // 스타일 선택
                        Picker("스타일", selection: $selectedStyle) {
                            Text("애니메이션").tag(ImagePlaygroundStyle.animation)
                            Text("일러스트").tag(ImagePlaygroundStyle.illustration)
                            Text("스케치").tag(ImagePlaygroundStyle.sketch)
                        }
                        .pickerStyle(.segmented)
                        
                        // 생성 버튼
                        Button {
                            showPlayground = true
                        } label: {
                            Label("이미지 생성", systemImage: "wand.and.stars")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .disabled(prompt.isEmpty)
                    }
                    .padding()
                }
            }
            .navigationTitle("Image Playground")
            .toolbar {
                if !generatedImages.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("모두 삭제") {
                            generatedImages.removeAll()
                        }
                    }
                }
            }
            .imagePlaygroundSheet(
                isPresented: $showPlayground,
                concepts: [.text(prompt)],
                style: selectedStyle,
                title: "이미지 생성"
            ) { url in
                generatedImages.append(url)
                prompt = ""
            }
            .task {
                // 지원 여부 확인
                isSupported = ImagePlaygroundViewController.isAvailable
            }
        }
    }
    
    func copyImage(from url: URL) {
        if let data = try? Data(contentsOf: url),
           let image = UIImage(data: data) {
            UIPasteboard.general.image = image
        }
    }
}

#Preview {
    ImagePlaygroundView()
}
```

## 고급 패턴

### 1. 여러 Concept 조합

```swift
struct MultiConceptView: View {
    @State private var showPlayground = false
    @State private var result: URL?
    
    var body: some View {
        Button("생성") {
            showPlayground = true
        }
        .imagePlaygroundSheet(
            isPresented: $showPlayground,
            concepts: [
                .text("판타지 성"),
                .text("눈 덮인 산"),
                .extracted(from: "마법사가 주문을 외우고 있다", title: "마법사")
            ],
            style: .illustration
        ) { url in
            result = url
        }
    }
}
```

### 2. UIKit 통합 (ImagePlaygroundViewController)

```swift
import UIKit
import ImagePlayground

class ImagePlaygroundHostVC: UIViewController {
    
    func presentPlayground() {
        guard ImagePlaygroundViewController.isAvailable else {
            showUnsupportedAlert()
            return
        }
        
        let playgroundVC = ImagePlaygroundViewController()
        playgroundVC.delegate = self
        
        // 초기 개념 설정
        playgroundVC.concepts = [
            .text("귀여운 로봇")
        ]
        
        // 스타일 설정
        playgroundVC.style = .animation
        
        present(playgroundVC, animated: true)
    }
    
    func showUnsupportedAlert() {
        let alert = UIAlertController(
            title: "지원되지 않음",
            message: "이 기기에서는 Image Playground를 사용할 수 없습니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

extension ImagePlaygroundHostVC: ImagePlaygroundViewControllerDelegate {
    func imagePlaygroundViewController(
        _ controller: ImagePlaygroundViewController,
        didCreateImageAt imageURL: URL
    ) {
        // 생성된 이미지 처리
        if let data = try? Data(contentsOf: imageURL),
           let image = UIImage(data: data) {
            // 이미지 사용
            handleGeneratedImage(image)
        }
        controller.dismiss(animated: true)
    }
    
    func imagePlaygroundViewControllerDidCancel(
        _ controller: ImagePlaygroundViewController
    ) {
        controller.dismiss(animated: true)
    }
    
    func handleGeneratedImage(_ image: UIImage) {
        // 이미지 처리 로직
    }
}
```

### 3. 사람 포함 이미지 생성

```swift
import SwiftUI
import ImagePlayground

struct PersonImageView: View {
    @State private var showPlayground = false
    @State private var result: URL?
    
    // 사람 사진 URL
    let personPhotoURL: URL
    
    var body: some View {
        Button("내 캐릭터 생성") {
            showPlayground = true
        }
        .imagePlaygroundSheet(
            isPresented: $showPlayground,
            concepts: [
                .person(
                    url: personPhotoURL,
                    nameComponents: PersonNameComponents(givenName: "철수")
                ),
                .text("우주 비행사")
            ],
            style: .animation
        ) { url in
            result = url
        }
    }
}
```

### 4. 지원 여부 체크 후 대체 UI

```swift
struct AdaptiveImageView: View {
    var body: some View {
        if ImagePlaygroundViewController.isAvailable {
            ImagePlaygroundView()
        } else {
            // 대체 UI (예: 스티커 선택기)
            StickerPickerView()
        }
    }
}
```

### 5. 이미지 저장 및 공유

```swift
func saveToPhotos(url: URL) async throws {
    let data = try Data(contentsOf: url)
    guard let image = UIImage(data: data) else { return }
    
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
}

// ShareLink 사용
struct ShareableImageView: View {
    let imageURL: URL
    
    var body: some View {
        VStack {
            AsyncImage(url: imageURL) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                ProgressView()
            }
            
            ShareLink(
                item: imageURL,
                preview: SharePreview("생성된 이미지", image: imageURL)
            ) {
                Label("공유", systemImage: "square.and.arrow.up")
            }
        }
    }
}
```

## 주의사항

1. **기기 요구사항**
   ```swift
   // 런타임 확인 필수
   if ImagePlaygroundViewController.isAvailable {
       // 사용 가능
   } else {
       // 대체 UI 표시
   }
   ```

2. **지원 기기**
   - iPhone 15 Pro / Pro Max 이상
   - M1 이상 iPad / Mac
   - 시뮬레이터 미지원

3. **이미지 특성**
   - 생성 이미지는 임시 URL로 제공됨
   - 영구 저장 필요 시 직접 복사

4. **개인정보**
   - 사람 이미지 사용 시 명시적 동의 필요
   - 생성된 이미지는 로컬 처리

5. **스타일 제한**
   - 세 가지 스타일만 지원 (animation, illustration, sketch)
   - 사실적인 이미지 생성 불가
   - 텍스트 렌더링 제한적
