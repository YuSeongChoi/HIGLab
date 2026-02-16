import Foundation
import CoreGraphics

/// 감지된 얼굴 정보
struct DetectedFace: Identifiable {
    let id = UUID()
    let boundingBox: CGRect  // 정규화 좌표
    let frame: CGRect        // UIKit 좌표
    let roll: Double         // 기울기 (z축 회전)
    let yaw: Double          // 좌우 회전 (y축 회전)
    let confidence: Double
    
    var landmarks: FaceLandmarks?
}
