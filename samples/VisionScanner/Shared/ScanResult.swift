//
//  ScanResult.swift
//  VisionScanner
//
//  스캔 결과를 담는 모델들
//

import Foundation
import Vision

// MARK: - 스캔 결과 타입

/// 스캔 결과의 종류를 나타내는 열거형
enum ScanResultType: String, CaseIterable, Identifiable {
    case text = "텍스트"
    case barcode = "바코드"
    case face = "얼굴"
    
    var id: String { rawValue }
    
    /// 시스템 아이콘 이름
    var iconName: String {
        switch self {
        case .text: return "doc.text.viewfinder"
        case .barcode: return "barcode.viewfinder"
        case .face: return "face.smiling"
        }
    }
}

// MARK: - 텍스트 인식 결과

/// OCR 텍스트 인식 결과
struct TextRecognitionResult: Identifiable {
    let id = UUID()
    
    /// 인식된 텍스트
    let text: String
    
    /// 신뢰도 (0.0 ~ 1.0)
    let confidence: Float
    
    /// 텍스트 영역의 바운딩 박스 (정규화된 좌표)
    let boundingBox: CGRect
    
    /// 신뢰도를 퍼센트로 표시
    var confidencePercentage: String {
        String(format: "%.1f%%", confidence * 100)
    }
}

// MARK: - 바코드 스캔 결과

/// 바코드/QR 코드 스캔 결과
struct BarcodeResult: Identifiable {
    let id = UUID()
    
    /// 바코드에 담긴 페이로드 (텍스트, URL 등)
    let payload: String
    
    /// 바코드 종류 (QR, EAN-13, Code128 등)
    let symbology: VNBarcodeSymbology
    
    /// 바코드 영역의 바운딩 박스
    let boundingBox: CGRect
    
    /// 바코드 종류를 읽기 쉬운 문자열로 변환
    var symbologyName: String {
        switch symbology {
        case .qr: return "QR 코드"
        case .ean13: return "EAN-13"
        case .ean8: return "EAN-8"
        case .code128: return "Code 128"
        case .code39: return "Code 39"
        case .upce: return "UPC-E"
        case .aztec: return "Aztec"
        case .pdf417: return "PDF417"
        case .dataMatrix: return "Data Matrix"
        default: return symbology.rawValue
        }
    }
    
    /// URL인지 확인
    var isURL: Bool {
        payload.hasPrefix("http://") || payload.hasPrefix("https://")
    }
}

// MARK: - 얼굴 인식 결과

/// 얼굴 인식 결과
struct FaceDetectionResult: Identifiable {
    let id = UUID()
    
    /// 얼굴 영역의 바운딩 박스
    let boundingBox: CGRect
    
    /// 얼굴 랜드마크 (눈, 코, 입 등)
    let landmarks: VNFaceLandmarks2D?
    
    /// 얼굴 각도 (yaw - 좌우 회전)
    let yaw: CGFloat?
    
    /// 얼굴 각도 (roll - 기울기)
    let roll: CGFloat?
    
    /// 얼굴 방향 설명
    var faceOrientationDescription: String {
        guard let yaw = yaw else { return "알 수 없음" }
        
        let yawDegrees = yaw * 180 / .pi
        if abs(yawDegrees) < 15 {
            return "정면"
        } else if yawDegrees > 0 {
            return "오른쪽으로 \(Int(abs(yawDegrees)))° 회전"
        } else {
            return "왼쪽으로 \(Int(abs(yawDegrees)))° 회전"
        }
    }
    
    /// 랜드마크 개수
    var landmarkCount: Int {
        guard let landmarks = landmarks else { return 0 }
        var count = 0
        if landmarks.leftEye != nil { count += 1 }
        if landmarks.rightEye != nil { count += 1 }
        if landmarks.nose != nil { count += 1 }
        if landmarks.outerLips != nil { count += 1 }
        if landmarks.leftEyebrow != nil { count += 1 }
        if landmarks.rightEyebrow != nil { count += 1 }
        return count
    }
}

// MARK: - 통합 스캔 결과

/// 모든 종류의 스캔 결과를 담는 컨테이너
struct ScanResults {
    var textResults: [TextRecognitionResult] = []
    var barcodeResults: [BarcodeResult] = []
    var faceResults: [FaceDetectionResult] = []
    
    /// 결과가 비어있는지 확인
    var isEmpty: Bool {
        textResults.isEmpty && barcodeResults.isEmpty && faceResults.isEmpty
    }
    
    /// 전체 결과 개수
    var totalCount: Int {
        textResults.count + barcodeResults.count + faceResults.count
    }
    
    /// 결과 초기화
    mutating func clear() {
        textResults.removeAll()
        barcodeResults.removeAll()
        faceResults.removeAll()
    }
}
