import SwiftUI
import PencilKit

// MARK: - CanvasView
// PKCanvasView를 SwiftUI에서 사용하기 위한 래퍼

struct CanvasView: UIViewRepresentable {
    // MARK: - 바인딩
    
    /// PKDrawing 데이터
    @Binding var drawing: PKDrawing
    
    /// 현재 도구
    var tool: PKTool
    
    /// 그리기 정책 (Apple Pencil만 / 손가락 허용)
    var drawingPolicy: PKCanvasViewDrawingPolicy = .anyInput
    
    /// 드로잉 변경 콜백
    var onDrawingChanged: ((PKDrawing) -> Void)?
    
    // MARK: - UIViewRepresentable
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        
        // 기본 설정
        canvasView.backgroundColor = .systemBackground
        canvasView.isOpaque = false
        canvasView.drawingPolicy = drawingPolicy
        canvasView.tool = tool
        canvasView.drawing = drawing
        
        // 델리게이트 설정
        canvasView.delegate = context.coordinator
        
        // 줌 및 스크롤 설정
        canvasView.minimumZoomScale = 0.5
        canvasView.maximumZoomScale = 5.0
        canvasView.bouncesZoom = true
        
        return canvasView
    }
    
    func updateUIView(_ canvasView: PKCanvasView, context: Context) {
        // 도구 업데이트
        canvasView.tool = tool
        
        // 드로잉 정책 업데이트
        canvasView.drawingPolicy = drawingPolicy
        
        // 드로잉이 다르면 업데이트 (외부에서 변경된 경우)
        if canvasView.drawing != drawing {
            canvasView.drawing = drawing
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: CanvasView
        
        init(_ parent: CanvasView) {
            self.parent = parent
        }
        
        /// 드로잉이 변경되었을 때 호출
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            // 바인딩 업데이트
            parent.drawing = canvasView.drawing
            
            // 콜백 호출
            parent.onDrawingChanged?(canvasView.drawing)
        }
    }
}

// MARK: - 확장: 도구 픽커 지원

extension CanvasView {
    /// PKToolPicker를 표시하는 버전
    struct WithToolPicker: UIViewRepresentable {
        @Binding var drawing: PKDrawing
        @Binding var isToolPickerVisible: Bool
        var drawingPolicy: PKCanvasViewDrawingPolicy = .anyInput
        var onDrawingChanged: ((PKDrawing) -> Void)?
        
        func makeUIView(context: Context) -> PKCanvasView {
            let canvasView = PKCanvasView()
            
            canvasView.backgroundColor = .systemBackground
            canvasView.isOpaque = false
            canvasView.drawingPolicy = drawingPolicy
            canvasView.drawing = drawing
            canvasView.delegate = context.coordinator
            
            // 줌 설정
            canvasView.minimumZoomScale = 0.5
            canvasView.maximumZoomScale = 5.0
            
            // 툴 픽커 설정
            if let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows.first {
                let toolPicker = PKToolPicker.shared(for: window)
                toolPicker?.setVisible(isToolPickerVisible, forFirstResponder: canvasView)
                toolPicker?.addObserver(canvasView)
                
                // 첫 번째 응답자로 설정
                DispatchQueue.main.async {
                    canvasView.becomeFirstResponder()
                }
            }
            
            return canvasView
        }
        
        func updateUIView(_ canvasView: PKCanvasView, context: Context) {
            canvasView.drawingPolicy = drawingPolicy
            
            if canvasView.drawing != drawing {
                canvasView.drawing = drawing
            }
            
            // 툴 픽커 가시성 업데이트
            if let window = canvasView.window {
                let toolPicker = PKToolPicker.shared(for: window)
                toolPicker?.setVisible(isToolPickerVisible, forFirstResponder: canvasView)
            }
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, PKCanvasViewDelegate {
            var parent: WithToolPicker
            
            init(_ parent: WithToolPicker) {
                self.parent = parent
            }
            
            func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
                parent.drawing = canvasView.drawing
                parent.onDrawingChanged?(canvasView.drawing)
            }
        }
    }
}

// MARK: - 미리보기

#Preview {
    @Previewable @State var drawing = PKDrawing()
    
    CanvasView(
        drawing: $drawing,
        tool: PKInkingTool(.pen, color: .black, width: 5)
    )
}
