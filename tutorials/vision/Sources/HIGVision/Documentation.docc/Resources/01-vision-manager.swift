import Vision
import UIKit
import Observation

@Observable
final class VisionManager {
    var isProcessing = false
    var errorMessage: String?
    
    // 분석 결과 저장
    var textResults: [RecognizedText] = []
    var faceResults: [DetectedFace] = []
    var barcodeResults: [ScannedBarcode] = []
    var documentBounds: DocumentBounds?
    
    init() {}
}
