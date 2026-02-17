//
//  VisionManager.swift
//  VisionScanner
//
//  Vision 프레임워크 요청을 래핑하는 매니저
//

import Foundation
import Vision
import UIKit

// MARK: - Vision 매니저

/// Vision 프레임워크를 사용한 이미지 분석 매니저
@MainActor
class VisionManager: ObservableObject {
    
    // MARK: - 상태
    
    /// 처리 중 여부
    @Published var isProcessing = false
    
    /// 에러 메시지
    @Published var errorMessage: String?
    
    // MARK: - 텍스트 인식 (OCR)
    
    /// 이미지에서 텍스트를 인식합니다
    /// - Parameters:
    ///   - image: 분석할 UIImage
    ///   - recognitionLevel: 인식 정확도 (.accurate 또는 .fast)
    ///   - languages: 인식할 언어 목록 (예: ["ko-KR", "en-US"])
    /// - Returns: 인식된 텍스트 결과 배열
    func recognizeText(
        in image: UIImage,
        recognitionLevel: VNRequestTextRecognitionLevel = .accurate,
        languages: [String] = ["ko-KR", "en-US"]
    ) async -> [TextRecognitionResult] {
        
        guard let cgImage = image.cgImage else {
            errorMessage = "이미지를 변환할 수 없습니다"
            return []
        }
        
        isProcessing = true
        defer { isProcessing = false }
        
        return await withCheckedContinuation { continuation in
            var results: [TextRecognitionResult] = []
            
            // 텍스트 인식 요청 생성
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    Task { @MainActor in
                        self.errorMessage = "텍스트 인식 실패: \(error.localizedDescription)"
                    }
                    continuation.resume(returning: [])
                    return
                }
                
                // 결과 처리
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                
                for observation in observations {
                    // 가장 신뢰도 높은 후보 선택
                    guard let topCandidate = observation.topCandidates(1).first else { continue }
                    
                    let result = TextRecognitionResult(
                        text: topCandidate.string,
                        confidence: topCandidate.confidence,
                        boundingBox: observation.boundingBox
                    )
                    results.append(result)
                }
                
                continuation.resume(returning: results)
            }
            
            // 요청 설정
            request.recognitionLevel = recognitionLevel
            request.recognitionLanguages = languages
            request.usesLanguageCorrection = true  // 언어 교정 활성화
            
            // 요청 실행
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                Task { @MainActor in
                    self.errorMessage = "요청 실행 실패: \(error.localizedDescription)"
                }
                continuation.resume(returning: [])
            }
        }
    }
    
    // MARK: - 바코드 스캔
    
    /// 이미지에서 바코드/QR 코드를 스캔합니다
    /// - Parameters:
    ///   - image: 분석할 UIImage
    ///   - symbologies: 인식할 바코드 종류 (기본값: 모든 종류)
    /// - Returns: 인식된 바코드 결과 배열
    func scanBarcodes(
        in image: UIImage,
        symbologies: [VNBarcodeSymbology] = [.qr, .ean13, .ean8, .code128, .code39, .upce, .aztec, .pdf417, .dataMatrix]
    ) async -> [BarcodeResult] {
        
        guard let cgImage = image.cgImage else {
            errorMessage = "이미지를 변환할 수 없습니다"
            return []
        }
        
        isProcessing = true
        defer { isProcessing = false }
        
        return await withCheckedContinuation { continuation in
            var results: [BarcodeResult] = []
            
            // 바코드 인식 요청 생성
            let request = VNDetectBarcodesRequest { request, error in
                if let error = error {
                    Task { @MainActor in
                        self.errorMessage = "바코드 스캔 실패: \(error.localizedDescription)"
                    }
                    continuation.resume(returning: [])
                    return
                }
                
                // 결과 처리
                guard let observations = request.results as? [VNBarcodeObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                
                for observation in observations {
                    guard let payload = observation.payloadStringValue else { continue }
                    
                    let result = BarcodeResult(
                        payload: payload,
                        symbology: observation.symbology,
                        boundingBox: observation.boundingBox
                    )
                    results.append(result)
                }
                
                continuation.resume(returning: results)
            }
            
            // 인식할 바코드 종류 설정
            request.symbologies = symbologies
            
            // 요청 실행
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                Task { @MainActor in
                    self.errorMessage = "요청 실행 실패: \(error.localizedDescription)"
                }
                continuation.resume(returning: [])
            }
        }
    }
    
    // MARK: - 얼굴 인식
    
    /// 이미지에서 얼굴을 인식합니다
    /// - Parameters:
    ///   - image: 분석할 UIImage
    ///   - detectLandmarks: 랜드마크(눈, 코, 입) 검출 여부
    /// - Returns: 인식된 얼굴 결과 배열
    func detectFaces(
        in image: UIImage,
        detectLandmarks: Bool = true
    ) async -> [FaceDetectionResult] {
        
        guard let cgImage = image.cgImage else {
            errorMessage = "이미지를 변환할 수 없습니다"
            return []
        }
        
        isProcessing = true
        defer { isProcessing = false }
        
        return await withCheckedContinuation { continuation in
            var results: [FaceDetectionResult] = []
            
            // 얼굴 인식 요청 생성 (랜드마크 포함 여부에 따라 다른 요청 사용)
            let request: VNImageBasedRequest
            
            if detectLandmarks {
                // 랜드마크 검출 요청
                let landmarkRequest = VNDetectFaceLandmarksRequest { request, error in
                    if let error = error {
                        Task { @MainActor in
                            self.errorMessage = "얼굴 인식 실패: \(error.localizedDescription)"
                        }
                        continuation.resume(returning: [])
                        return
                    }
                    
                    guard let observations = request.results as? [VNFaceObservation] else {
                        continuation.resume(returning: [])
                        return
                    }
                    
                    for observation in observations {
                        let result = FaceDetectionResult(
                            boundingBox: observation.boundingBox,
                            landmarks: observation.landmarks,
                            yaw: observation.yaw?.doubleValue.map { CGFloat($0) },
                            roll: observation.roll?.doubleValue.map { CGFloat($0) }
                        )
                        results.append(result)
                    }
                    
                    continuation.resume(returning: results)
                }
                request = landmarkRequest
            } else {
                // 기본 얼굴 검출 요청 (더 빠름)
                let detectRequest = VNDetectFaceRectanglesRequest { request, error in
                    if let error = error {
                        Task { @MainActor in
                            self.errorMessage = "얼굴 인식 실패: \(error.localizedDescription)"
                        }
                        continuation.resume(returning: [])
                        return
                    }
                    
                    guard let observations = request.results as? [VNFaceObservation] else {
                        continuation.resume(returning: [])
                        return
                    }
                    
                    for observation in observations {
                        let result = FaceDetectionResult(
                            boundingBox: observation.boundingBox,
                            landmarks: nil,
                            yaw: observation.yaw?.doubleValue.map { CGFloat($0) },
                            roll: observation.roll?.doubleValue.map { CGFloat($0) }
                        )
                        results.append(result)
                    }
                    
                    continuation.resume(returning: results)
                }
                request = detectRequest
            }
            
            // 요청 실행
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                Task { @MainActor in
                    self.errorMessage = "요청 실행 실패: \(error.localizedDescription)"
                }
                continuation.resume(returning: [])
            }
        }
    }
    
    // MARK: - 에러 초기화
    
    /// 에러 메시지를 초기화합니다
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Vision 좌표 변환 헬퍼

extension VisionManager {
    
    /// Vision의 정규화된 좌표를 실제 뷰 좌표로 변환합니다
    /// Vision은 좌하단이 원점(0,0)이고, UIKit/SwiftUI는 좌상단이 원점입니다
    /// - Parameters:
    ///   - boundingBox: Vision에서 반환된 정규화된 바운딩 박스
    ///   - viewSize: 변환할 뷰의 크기
    /// - Returns: 뷰 좌표계의 CGRect
    static func convertBoundingBox(_ boundingBox: CGRect, to viewSize: CGSize) -> CGRect {
        // Y좌표 반전 (Vision은 좌하단 원점, SwiftUI는 좌상단 원점)
        let x = boundingBox.origin.x * viewSize.width
        let y = (1 - boundingBox.origin.y - boundingBox.height) * viewSize.height
        let width = boundingBox.width * viewSize.width
        let height = boundingBox.height * viewSize.height
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
