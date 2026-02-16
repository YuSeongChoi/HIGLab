import SwiftUI

struct DrawingCanvas: View {
    @ObservedObject var drawingManager: DrawingStreamManager
    @State private var currentPath = Path()
    @State private var paths: [(Path, Color)] = []
    @State private var selectedColor: Color = .black
    
    var body: some View {
        Canvas { context, size in
            // 저장된 경로들 그리기
            for (path, color) in paths {
                context.stroke(path, with: .color(color), lineWidth: 3)
            }
            // 현재 그리는 경로
            context.stroke(currentPath, with: .color(selectedColor), lineWidth: 3)
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let point = value.location
                    
                    if value.translation == .zero {
                        // 새 획 시작
                        currentPath = Path()
                        currentPath.move(to: point)
                        
                        // 스트림으로 전송
                        let drawingPoint = DrawingPoint(point: point, isStart: true)
                        drawingManager.sendDrawingPoint(drawingPoint)
                    } else {
                        currentPath.addLine(to: point)
                        
                        let drawingPoint = DrawingPoint(point: point, isStart: false)
                        drawingManager.sendDrawingPoint(drawingPoint)
                    }
                }
                .onEnded { _ in
                    paths.append((currentPath, selectedColor))
                    currentPath = Path()
                }
        )
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
