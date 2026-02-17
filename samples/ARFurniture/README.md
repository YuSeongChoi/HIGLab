# ARFurniture

ARKit과 RealityKit을 활용한 AR 가구 배치 샘플 앱입니다.

## 📱 기능

- **평면 감지**: 바닥 평면을 자동으로 인식
- **가구 카탈로그**: 카테고리별 가구 목록 탐색
- **AR 배치**: 탭하여 선택한 가구를 실제 공간에 배치
- **조절 기능**: 배치 전 회전/크기 조절
- **다중 배치**: 여러 가구를 동시에 배치

## 🏗 프로젝트 구조

```
ARFurniture/
├── Shared/                      # 공유 모델 및 유틸리티
│   ├── FurnitureItem.swift      # 가구 데이터 모델
│   ├── ARManager.swift          # AR 세션 관리
│   └── ModelLoader.swift        # USDZ 모델 로딩
│
├── ARFurnitureApp/              # 앱 소스
│   ├── ARFurnitureApp.swift     # 앱 진입점 (@main)
│   ├── ContentView.swift        # 메인 뷰 (AR + UI)
│   ├── ARViewContainer.swift    # ARView SwiftUI 래퍼
│   ├── CatalogView.swift        # 가구 카탈로그 뷰
│   └── PlacementView.swift      # 배치 컨트롤 뷰
│
└── README.md
```

## 🔧 요구사항

- iOS 16.0+
- Xcode 15.0+
- ARKit 지원 기기 (A12 Bionic 이상)

## 🚀 시작하기

### 1. Xcode 프로젝트 생성

1. Xcode에서 **File > New > Project** 선택
2. **iOS > App** 선택
3. 프로젝트 이름: `ARFurniture`
4. Interface: **SwiftUI**
5. Language: **Swift**

### 2. 파일 추가

위 구조에 따라 Swift 파일들을 프로젝트에 추가합니다.

### 3. Info.plist 설정

카메라 접근 권한을 위해 `Info.plist`에 다음 키를 추가하세요:

```xml
<key>NSCameraUsageDescription</key>
<string>AR 가구 배치를 위해 카메라 접근이 필요합니다.</string>
```

### 4. 3D 모델 추가 (선택)

실제 USDZ 모델을 사용하려면:

1. `.usdz` 파일을 프로젝트에 추가
2. `FurnitureItem.swift`의 `modelName`을 파일명과 일치하게 설정

> 💡 모델이 없어도 플레이스홀더 박스로 동작합니다.

## 📚 주요 컴포넌트

### ARManager

AR 세션의 핵심 관리자입니다.

```swift
// 세션 시작
arManager.setupSession(for: arView)

// 가구 선택
arManager.selectedFurniture = item

// 가구 배치
await arManager.placeFurniture(item, at: raycastResult)

// 세션 리셋
arManager.resetSession()
```

### ModelLoader

USDZ 모델 로딩 및 캐싱을 담당합니다.

```swift
let loader = ModelLoader()

// 모델 로드 (캐시 활용)
let entity = try await loader.loadModel(named: "chair")

// 원격 URL에서 로드
let remoteEntity = try await loader.downloadAndLoad(from: url)

// 프리로드
await loader.preloadModels(["chair", "table", "sofa"])
```

### FurnitureItem

가구 데이터 모델입니다.

```swift
let chair = FurnitureItem(
    name: "모던 의자",
    category: .chair,
    modelName: "modern_chair",
    price: 150000,
    dimensions: SIMD3<Float>(0.5, 0.5, 0.85),
    description: "심플한 모던 스타일 의자"
)
```

## 🎮 사용 방법

1. 앱 실행 후 기기를 천천히 움직여 바닥 평면을 스캔
2. "가구 선택" 버튼을 탭하여 카탈로그 열기
3. 원하는 가구의 "배치" 버튼 탭
4. 회전/크기를 조절 (선택)
5. 원하는 위치의 평면을 탭하여 배치
6. 추가 가구를 배치하거나 리셋 버튼으로 초기화

## 🎨 UI 구성

- **상단 바**: 리셋 버튼, 배치 개수, 설정
- **중앙**: AR 카메라 뷰
- **상태 표시**: 현재 AR 상태 메시지
- **하단 바**: 가구 선택 버튼
- **배치 컨트롤**: 선택된 가구의 회전/크기 조절

## ✨ 확장 아이디어

- [ ] 실제 3D 가구 모델 추가
- [ ] 가구 저장/불러오기
- [ ] 스크린샷 공유
- [ ] 측정 도구
- [ ] 조명 시뮬레이션
- [ ] 다중 평면 지원 (벽면 등)

## 📝 라이선스

HIG Lab 샘플 프로젝트입니다. 학습 및 참고용으로 자유롭게 사용하세요.
