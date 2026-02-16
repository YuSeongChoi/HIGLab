import Foundation
import CoreGraphics

// 드로잉 포인트 모델
struct DrawingPoint: Codable {
    let x: CGFloat
    let y: CGFloat
    let timestamp: TimeInterval
    let isStartOfStroke: Bool  // 새 획의 시작점인지
    let color: DrawingColor
    let lineWidth: CGFloat
    
    init(point: CGPoint, isStart: Bool, color: DrawingColor = .black, lineWidth: CGFloat = 3) {
        self.x = point.x
        self.y = point.y
        self.timestamp = Date().timeIntervalSince1970
        self.isStartOfStroke = isStart
        self.color = color
        self.lineWidth = lineWidth
    }
    
    var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }
}

struct DrawingColor: Codable {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat
    
    static let black = DrawingColor(red: 0, green: 0, blue: 0, alpha: 1)
    static let red = DrawingColor(red: 1, green: 0, blue: 0, alpha: 1)
    static let blue = DrawingColor(red: 0, green: 0, blue: 1, alpha: 1)
}
