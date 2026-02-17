# ImageMaker

iOS 26 Image Playground API를 활용한 AI 이미지 생성 샘플 앱

## 📱 개요

ImageMaker는 Apple의 Image Playground 프레임워크를 사용하여 텍스트 프롬프트로부터 AI 이미지를 생성하는 데모 앱입니다. iOS 26의 새로운 생성형 AI 기능을 SwiftUI와 함께 활용하는 방법을 보여줍니다.

## ✨ 주요 기능

1. **Image Playground 통합** - 시스템 Image Playground UI를 앱 내에서 표시
2. **텍스트 프롬프트 입력** - 자유로운 텍스트로 이미지 설명
3. **스타일 선택** - 애니메이션, 일러스트, 스케치 3가지 스타일
4. **이미지 저장** - 생성된 이미지를 앱 내 갤러리에 자동 저장
5. **히스토리 갤러리** - 그리드 레이아웃으로 생성 기록 탐색
6. **공유 기능** - 이미지를 사진 앱 저장 또는 다른 앱으로 공유

## 🏗️ 프로젝트 구조

```
ImageMaker/
├── Shared/                      # 공통 모델 및 유틸리티
│   ├── GeneratedImage.swift     # 생성된 이미지 데이터 모델
│   ├── ImageStyle.swift         # 스타일 열거형 및 프리셋
│   └── ImageStorageManager.swift # 이미지 저장/로드 관리
│
└── ImageMakerApp/               # 메인 앱 코드
    ├── ImageMakerApp.swift      # 앱 진입점 및 테마
    ├── ImageMakerViewModel.swift # 메인 뷰모델
    ├── ContentView.swift        # 탭 기반 메인 뷰
    ├── ImageGeneratorView.swift # 이미지 생성 화면
    ├── HistoryGalleryView.swift # 갤러리 화면
    └── ImageDetailView.swift    # 이미지 상세/공유 화면
```

## 🛠️ 기술 스택

- **SwiftUI** - 선언적 UI 프레임워크
- **ImagePlayground** - iOS 26 AI 이미지 생성 API
- **Observation** - 상태 관리 (@Observable)
- **Swift Concurrency** - async/await 비동기 처리

## 📋 요구 사항

- iOS 26.0+
- Xcode 26.0+
- Apple Silicon Mac (시뮬레이터) 또는 Apple Intelligence 지원 기기

## 🔑 핵심 API 사용법

### Image Playground Sheet 표시

```swift
import ImagePlayground

.imagePlaygroundSheet(
    isPresented: $showingPlayground,
    concepts: [.text("우주를 여행하는 고양이")],
    style: .animation
) { url in
    // 생성된 이미지 URL 처리
    handleGeneratedImage(url)
}
```

### 스타일 옵션

```swift
// iOS 26 ImagePlaygroundStyle
ImagePlaygroundStyle.animation    // 3D 애니메이션 스타일
ImagePlaygroundStyle.illustration // 손그림 일러스트
ImagePlaygroundStyle.sketch       // 연필 스케치
```

### 가용성 확인

```swift
if ImagePlaygroundViewController.isAvailable {
    // Image Playground 사용 가능
}
```

## 📊 파일 통계

| 폴더 | 파일 수 | 줄 수 |
|------|---------|-------|
| Shared/ | 3 | ~710 |
| ImageMakerApp/ | 6 | ~2,065 |
| **합계** | **9** | **~2,775** |

## 📝 주요 학습 포인트

1. **imagePlaygroundSheet 모디파이어** - SwiftUI에서 Image Playground 표시
2. **ImagePlaygroundConcept** - 텍스트/이미지 기반 컨셉 정의
3. **ImagePlaygroundStyle** - 생성 스타일 선택
4. **콜백 처리** - 생성된 이미지 URL 수신 및 저장
5. **가용성 체크** - Apple Intelligence 지원 여부 확인

## 🎨 UI 특징

- **탭 기반 네비게이션** - 만들기 / 갤러리 / 설정
- **그리드 레이아웃** - 2열 반응형 이미지 그리드
- **제스처 지원** - 핀치 줌, 더블 탭, 드래그
- **다크 모드** - 시스템 설정 자동 대응
- **햅틱 피드백** - 상호작용 시 촉각 반응

## ⚠️ 참고 사항

- Image Playground는 Apple Intelligence가 활성화된 기기에서만 동작합니다
- 시뮬레이터에서는 제한적으로 테스트 가능합니다
- 생성된 이미지는 앱의 Documents 디렉토리에 저장됩니다

## 📄 라이선스

이 샘플 코드는 HIG Lab 학습 목적으로 제작되었습니다.
