import Foundation
import CoreGraphics

/// 인식된 텍스트 결과 모델
struct RecognizedText: Identifiable {
    let id = UUID()
    let text: String
    let confidence: Float
    let boundingBox: CGRect  // 정규화 좌표 (0.0 ~ 1.0)
    
    var confidencePercent: Int {
        Int(confidence * 100)
    }
    
    var confidenceLevel: ConfidenceLevel {
        switch confidence {
        case 0.8...1.0: return .high
        case 0.5..<0.8: return .medium
        default: return .low
        }
    }
}

enum ConfidenceLevel {
    case high, medium, low
    
    var color: String {
        switch self {
        case .high: return "green"
        case .medium: return "orange"
        case .low: return "red"
        }
    }
}
