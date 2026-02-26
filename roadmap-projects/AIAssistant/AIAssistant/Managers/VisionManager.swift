import Foundation
import Vision
import UIKit

@Observable
final class VisionManager {
    private(set) var recognizedText = ""
    private(set) var detectedObjects: [DetectedObject] = []
    private(set) var isProcessing = false
    
    struct DetectedObject: Identifiable {
        let id = UUID()
        let label: String
        let confidence: Float
        let boundingBox: CGRect
    }
    
    // MARK: - Text Recognition (OCR)
    @MainActor
    func recognizeText(from image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        
        isProcessing = true
        defer { isProcessing = false }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                let text = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
                
                continuation.resume(returning: text)
            }
            
            // 한국어 + 영어 인식
            request.recognitionLanguages = ["ko-KR", "en-US"]
            request.recognitionLevel = .accurate
            
            let handler = VNImageRequestHandler(cgImage: cgImage)
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    // MARK: - Image Classification
    @MainActor
    func classifyImage(_ image: UIImage) async throws -> [DetectedObject] {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        
        isProcessing = true
        defer { isProcessing = false }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNClassifyImageRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let observations = request.results as? [VNClassificationObservation] ?? []
                let objects = observations.prefix(5).map { observation in
                    DetectedObject(
                        label: observation.identifier,
                        confidence: observation.confidence,
                        boundingBox: .zero
                    )
                }
                
                continuation.resume(returning: objects)
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage)
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    // MARK: - Face Detection
    @MainActor
    func detectFaces(in image: UIImage) async throws -> Int {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        
        isProcessing = true
        defer { isProcessing = false }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectFaceRectanglesRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let faceCount = request.results?.count ?? 0
                continuation.resume(returning: faceCount)
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage)
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    enum VisionError: LocalizedError {
        case invalidImage
        
        var errorDescription: String? {
            switch self {
            case .invalidImage:
                return "이미지를 처리할 수 없습니다."
            }
        }
    }
}
