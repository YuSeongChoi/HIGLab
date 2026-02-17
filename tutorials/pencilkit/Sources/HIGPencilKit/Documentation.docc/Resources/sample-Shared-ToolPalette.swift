import SwiftUI
import PencilKit

// MARK: - ToolType
// 사용 가능한 도구 유형

enum ToolType: String, CaseIterable, Identifiable {
    case pen = "펜"
    case pencil = "연필"
    case marker = "마커"
    case eraser = "지우개"
    case lasso = "올가미"
    
    var id: String { rawValue }
    
    /// 도구 아이콘
    var icon: String {
        switch self {
        case .pen: return "pencil.tip"
        case .pencil: return "pencil"
        case .marker: return "highlighter"
        case .eraser: return "eraser"
        case .lasso: return "lasso"
        }
    }
    
    /// 도구 설명
    var description: String {
        switch self {
        case .pen: return "부드럽고 정확한 선"
        case .pencil: return "자연스러운 연필 질감"
        case .marker: return "반투명 형광펜"
        case .eraser: return "스트로크 지우기"
        case .lasso: return "선택 및 이동"
        }
    }
}

// MARK: - ToolPalette
// 현재 선택된 도구 및 설정을 관리

@Observable
class ToolPalette {
    // MARK: - 속성
    
    /// 현재 선택된 도구
    var selectedTool: ToolType = .pen
    
    /// 현재 색상
    var selectedColor: Color = .black
    
    /// 선 두께 (1.0 ~ 20.0)
    var lineWidth: CGFloat = 5.0
    
    /// 지우개 크기
    var eraserWidth: CGFloat = 20.0
    
    /// 불투명도 (0.0 ~ 1.0)
    var opacity: Double = 1.0
    
    // MARK: - 프리셋 색상
    
    /// 기본 색상 팔레트
    static let presetColors: [Color] = [
        .black, .gray, .white,
        .red, .orange, .yellow,
        .green, .blue, .purple,
        .pink, .brown, .cyan
    ]
    
    // MARK: - 프리셋 두께
    
    /// 기본 두께 옵션
    static let presetWidths: [CGFloat] = [1, 3, 5, 8, 12, 20]
    
    // MARK: - PKTool 변환
    
    /// 현재 설정을 PKTool로 변환
    var pkTool: PKTool {
        let uiColor = UIColor(selectedColor).withAlphaComponent(opacity)
        
        switch selectedTool {
        case .pen:
            return PKInkingTool(.pen, color: uiColor, width: lineWidth)
        case .pencil:
            return PKInkingTool(.pencil, color: uiColor, width: lineWidth)
        case .marker:
            return PKInkingTool(.marker, color: uiColor, width: lineWidth)
        case .eraser:
            return PKEraserTool(.bitmap, width: eraserWidth)
        case .lasso:
            return PKLassoTool()
        }
    }
    
    // MARK: - 초기화
    
    init(
        tool: ToolType = .pen,
        color: Color = .black,
        lineWidth: CGFloat = 5.0,
        opacity: Double = 1.0
    ) {
        self.selectedTool = tool
        self.selectedColor = color
        self.lineWidth = lineWidth
        self.opacity = opacity
    }
    
    // MARK: - 편의 메서드
    
    /// 도구 선택
    func selectTool(_ tool: ToolType) {
        selectedTool = tool
    }
    
    /// 색상 선택
    func selectColor(_ color: Color) {
        selectedColor = color
    }
    
    /// 두께 조절
    func setLineWidth(_ width: CGFloat) {
        lineWidth = max(1, min(50, width))
    }
    
    /// 지우개 크기 조절
    func setEraserWidth(_ width: CGFloat) {
        eraserWidth = max(5, min(100, width))
    }
    
    /// 기본값으로 리셋
    func reset() {
        selectedTool = .pen
        selectedColor = .black
        lineWidth = 5.0
        eraserWidth = 20.0
        opacity = 1.0
    }
}

// MARK: - 미리보기용 확장

extension ToolPalette {
    /// 미리보기용 팔레트
    static var preview: ToolPalette {
        ToolPalette(tool: .pen, color: .blue, lineWidth: 5.0)
    }
}
