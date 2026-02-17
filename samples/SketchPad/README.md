# SketchPad

PencilKit을 활용한 드로잉 앱 샘플 프로젝트입니다.

## 개요

SketchPad는 Apple의 **PencilKit** 프레임워크를 사용하여 iPad 및 iPhone에서 자연스러운 드로잉 경험을 제공하는 앱입니다. Apple Pencil과 손가락 입력을 모두 지원합니다.

## 주요 기능

### 🎨 드로잉 도구
- **펜 (Pen)**: 부드럽고 정확한 선
- **연필 (Pencil)**: 자연스러운 연필 질감
- **마커 (Marker)**: 반투명 형광펜 효과
- **지우개 (Eraser)**: 스트로크 지우기
- **올가미 (Lasso)**: 선택 및 이동

### 🎨 색상 및 스타일
- 12가지 프리셋 색상
- 커스텀 색상 선택 (ColorPicker)
- 선 두께 조절 (1~50pt)
- 불투명도 조절 (10~100%)

### 💾 저장 및 관리
- 드로잉 자동 저장
- 썸네일 자동 생성
- 드로잉 목록 관리 (생성/삭제/이름변경)
- 정렬 옵션 (수정일/생성일/이름)

### 📤 내보내기
- **PNG**: 투명 배경 지원, 무손실 품질
- **JPEG**: 작은 파일 크기
- **PDF**: 벡터 기반, 인쇄용
- 배경색 및 크기 배율 설정

## 프로젝트 구조

```
SketchPad/
├── Shared/
│   ├── Drawing.swift          # PKDrawing 래퍼 모델
│   ├── DrawingStore.swift     # 저장/로드 관리
│   └── ToolPalette.swift      # 도구 설정 관리
│
├── SketchPadApp/
│   ├── SketchPadApp.swift     # 앱 진입점 (@main)
│   ├── ContentView.swift      # 드로잉 목록 (메인 화면)
│   ├── CanvasView.swift       # PKCanvasView 래퍼
│   ├── DrawingView.swift      # 캔버스 + 툴바
│   ├── ToolPickerView.swift   # 도구 선택 시트
│   └── ExportView.swift       # 내보내기 시트
│
└── README.md
```

## 핵심 컴포넌트

### Drawing.swift
`PKDrawing`을 `Identifiable`하고 `Codable`한 모델로 래핑합니다.

```swift
struct Drawing: Identifiable, Codable {
    let id: UUID
    var name: String
    var drawingData: Data  // PKDrawing.dataRepresentation()
    var thumbnailData: Data?
    // ...
}
```

### DrawingStore.swift
`@Observable` 클래스로 드로잉 목록의 CRUD 및 영속성을 관리합니다.

```swift
@Observable
class DrawingStore {
    var drawings: [Drawing] = []
    
    func createDrawing(name: String) -> Drawing
    func updateDrawing(_ drawing: Drawing)
    func deleteDrawing(_ drawing: Drawing)
    func save()
    func load() async
}
```

### CanvasView.swift
`PKCanvasView`를 SwiftUI에서 사용하기 위한 `UIViewRepresentable` 래퍼입니다.

```swift
struct CanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    var tool: PKTool
    var onDrawingChanged: ((PKDrawing) -> Void)?
}
```

### ToolPalette.swift
현재 선택된 도구, 색상, 두께 등의 설정을 관리합니다.

```swift
@Observable
class ToolPalette {
    var selectedTool: ToolType = .pen
    var selectedColor: Color = .black
    var lineWidth: CGFloat = 5.0
    
    var pkTool: PKTool { /* 현재 설정을 PKTool로 변환 */ }
}
```

## Apple HIG 준수 사항

### 레이아웃
- **NavigationSplitView**: iPad에서 사이드바 + 디테일 레이아웃
- **presentationDetents**: 시트의 적절한 높이 설정

### 입력
- **Apple Pencil 최적화**: `drawingPolicy` 설정
- **손가락 입력 지원**: 접근성 고려

### 피드백
- **ProgressView**: 로딩 상태 표시
- **ContentUnavailableView**: 빈 상태 안내

### 내보내기
- **UIActivityViewController**: 시스템 공유 시트 활용
- **다양한 형식 지원**: PNG, JPEG, PDF

## 요구 사항

- iOS 17.0+
- iPadOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## 사용된 프레임워크

- **SwiftUI**: UI 구성
- **PencilKit**: 드로잉 기능
- **Observation**: 상태 관리 (@Observable)

## 라이선스

HIG Lab 샘플 프로젝트로 교육 및 학습 목적으로 제공됩니다.
