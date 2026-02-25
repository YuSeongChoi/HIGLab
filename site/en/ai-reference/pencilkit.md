# PencilKit AI Reference

> Apple Pencil 드로잉 구현 가이드. 이 문서를 읽고 PencilKit 코드를 생성할 수 있습니다.

## 개요

PencilKit은 Apple Pencil과 손가락으로 자연스러운 드로잉 경험을 제공하는 프레임워크입니다.
그리기, 지우기, 도구 선택, 드로잉 저장/로드를 지원합니다.

## 필수 Import

```swift
import PencilKit
import SwiftUI
```

## 핵심 구성요소

### 1. PKCanvasView

```swift
let canvasView = PKCanvasView()
canvasView.drawingPolicy = .anyInput  // 손가락 + 펜슬
canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
canvasView.backgroundColor = .white
```

### 2. PKToolPicker

```swift
let toolPicker = PKToolPicker()
toolPicker.setVisible(true, forFirstResponder: canvasView)
toolPicker.addObserver(canvasView)
canvasView.becomeFirstResponder()
```

### 3. PKDrawing

```swift
// 드로잉 가져오기
let drawing = canvasView.drawing

// 드로잉 설정
canvasView.drawing = PKDrawing()

// 이미지로 변환
let image = drawing.image(from: drawing.bounds, scale: 2.0)

// 데이터로 저장
let data = drawing.dataRepresentation()

// 데이터에서 로드
let loadedDrawing = try PKDrawing(data: data)
```

## 전체 작동 예제

```swift
import SwiftUI
import PencilKit

// MARK: - Canvas View Wrapper
struct CanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    @Binding var tool: PKTool
    let showToolPicker: Bool
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.drawing = drawing
        canvasView.tool = tool
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .white
        canvasView.delegate = context.coordinator
        
        // 도구 피커
        if showToolPicker {
            let toolPicker = PKToolPicker()
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            canvasView.becomeFirstResponder()
            context.coordinator.toolPicker = toolPicker
        }
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.tool = tool
        
        if uiView.drawing != drawing {
            uiView.drawing = drawing
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(drawing: $drawing)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding var drawing: PKDrawing
        var toolPicker: PKToolPicker?
        
        init(drawing: Binding<PKDrawing>) {
            _drawing = drawing
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            drawing = canvasView.drawing
        }
    }
}

// MARK: - Drawing Manager
@Observable
class DrawingManager {
    var drawing = PKDrawing()
    var tool: PKTool = PKInkingTool(.pen, color: .black, width: 5)
    var selectedColor: Color = .black
    var selectedWidth: CGFloat = 5
    var toolType: ToolType = .pen
    
    enum ToolType: String, CaseIterable {
        case pen = "펜"
        case pencil = "연필"
        case marker = "마커"
        case eraser = "지우개"
    }
    
    var canUndo: Bool {
        !drawing.strokes.isEmpty
    }
    
    func updateTool() {
        let uiColor = UIColor(selectedColor)
        
        switch toolType {
        case .pen:
            tool = PKInkingTool(.pen, color: uiColor, width: selectedWidth)
        case .pencil:
            tool = PKInkingTool(.pencil, color: uiColor, width: selectedWidth)
        case .marker:
            tool = PKInkingTool(.marker, color: uiColor, width: selectedWidth * 2)
        case .eraser:
            tool = PKEraserTool(.bitmap)
        }
    }
    
    func clear() {
        drawing = PKDrawing()
    }
    
    func save() -> Data {
        drawing.dataRepresentation()
    }
    
    func load(from data: Data) {
        if let loadedDrawing = try? PKDrawing(data: data) {
            drawing = loadedDrawing
        }
    }
    
    func exportImage(scale: CGFloat = 2.0) -> UIImage {
        drawing.image(from: drawing.bounds, scale: scale)
    }
}

// MARK: - Views
struct SketchPadView: View {
    @State private var manager = DrawingManager()
    @State private var showToolPicker = false
    @State private var showingExport = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 캔버스
                CanvasView(
                    drawing: $manager.drawing,
                    tool: $manager.tool,
                    showToolPicker: showToolPicker
                )
                
                // 커스텀 도구바
                if !showToolPicker {
                    customToolbar
                }
            }
            .navigationTitle("스케치패드")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("지우기", role: .destructive) {
                        manager.clear()
                    }
                    .disabled(!manager.canUndo)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Toggle("시스템 도구 피커", isOn: $showToolPicker)
                        
                        Button {
                            showingExport = true
                        } label: {
                            Label("이미지로 저장", systemImage: "square.and.arrow.down")
                        }
                        
                        ShareLink(item: Image(uiImage: manager.exportImage()), preview: SharePreview("스케치", image: Image(uiImage: manager.exportImage()))) {
                            Label("공유", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("저장 완료", isPresented: $showingExport) {
                Button("확인") {}
            } message: {
                Text("이미지가 사진 앱에 저장되었습니다")
            }
        }
    }
    
    var customToolbar: some View {
        VStack(spacing: 12) {
            // 도구 선택
            HStack(spacing: 16) {
                ForEach(DrawingManager.ToolType.allCases, id: \.self) { type in
                    Button {
                        manager.toolType = type
                        manager.updateTool()
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: iconFor(type))
                                .font(.title2)
                            Text(type.rawValue)
                                .font(.caption2)
                        }
                        .foregroundStyle(manager.toolType == type ? .blue : .primary)
                    }
                }
            }
            
            if manager.toolType != .eraser {
                // 색상 선택
                HStack(spacing: 12) {
                    ForEach([Color.black, .red, .orange, .yellow, .green, .blue, .purple], id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 30, height: 30)
                            .overlay {
                                if manager.selectedColor == color {
                                    Circle()
                                        .stroke(.white, lineWidth: 2)
                                        .padding(2)
                                }
                            }
                            .onTapGesture {
                                manager.selectedColor = color
                                manager.updateTool()
                            }
                    }
                    
                    ColorPicker("", selection: $manager.selectedColor)
                        .labelsHidden()
                        .onChange(of: manager.selectedColor) { _, _ in
                            manager.updateTool()
                        }
                }
                
                // 굵기 선택
                HStack {
                    Text("굵기")
                        .font(.caption)
                    Slider(value: $manager.selectedWidth, in: 1...20)
                        .onChange(of: manager.selectedWidth) { _, _ in
                            manager.updateTool()
                        }
                    Text("\(Int(manager.selectedWidth))")
                        .font(.caption)
                        .frame(width: 30)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
    }
    
    func iconFor(_ type: DrawingManager.ToolType) -> String {
        switch type {
        case .pen: return "pencil.tip"
        case .pencil: return "pencil"
        case .marker: return "highlighter"
        case .eraser: return "eraser"
        }
    }
}
```

## 고급 패턴

### 1. Lasso 선택 도구

```swift
let lassoTool = PKLassoTool()
canvasView.tool = lassoTool

// 선택된 스트로크 처리
// PKCanvasViewDelegate의 canvasViewDidFinishRendering에서 처리
```

### 2. 스트로크 분석

```swift
func analyzeStrokes(_ drawing: PKDrawing) {
    for stroke in drawing.strokes {
        let path = stroke.path
        let ink = stroke.ink
        
        print("색상: \(ink.color)")
        print("도구: \(ink.inkType)")
        print("포인트 수: \(path.count)")
        
        // 각 포인트 정보
        for i in 0..<path.count {
            let point = path[i]
            print("위치: \(point.location), 압력: \(point.force)")
        }
    }
}
```

### 3. 투명 배경 이미지

```swift
func exportWithTransparentBackground(drawing: PKDrawing) -> UIImage {
    let bounds = drawing.bounds
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, false, 2.0)
    
    // 투명 배경
    UIColor.clear.setFill()
    UIRectFill(CGRect(origin: .zero, size: bounds.size))
    
    // 드로잉 렌더링
    let image = drawing.image(from: bounds, scale: 2.0)
    image.draw(at: .zero)
    
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return result ?? UIImage()
}
```

### 4. 드로잉 병합

```swift
func mergeDrawings(_ drawings: [PKDrawing]) -> PKDrawing {
    var allStrokes: [PKStroke] = []
    
    for drawing in drawings {
        allStrokes.append(contentsOf: drawing.strokes)
    }
    
    return PKDrawing(strokes: allStrokes)
}
```

## 주의사항

1. **Apple Pencil 최적화**
   - `drawingPolicy = .pencilOnly`: 펜슬만 드로잉
   - `drawingPolicy = .anyInput`: 손가락도 드로잉
   - `drawingPolicy = .default`: 시스템 설정 따름

2. **메모리 관리**
   - 복잡한 드로잉은 메모리 사용 증가
   - 이미지 내보내기 시 scale 조절

3. **데이터 저장**
   ```swift
   // 저장
   let data = drawing.dataRepresentation()
   try data.write(to: fileURL)
   
   // 로드
   let data = try Data(contentsOf: fileURL)
   let drawing = try PKDrawing(data: data)
   ```

4. **시뮬레이터 테스트**
   - 마우스/트랙패드로 테스트 가능
   - 압력 감지는 실제 기기에서만
