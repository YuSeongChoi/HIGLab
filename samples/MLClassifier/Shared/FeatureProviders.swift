import Foundation
import CoreML
import CoreImage
import CoreVideo

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - 피처 제공자
// MLFeatureProvider, MLMultiArray, MLPredictionOptions를 활용한 커스텀 입력 처리

/// 이미지 피처 제공자
/// CoreML 모델에 이미지 입력을 제공하기 위한 MLFeatureProvider 구현
final class ImageFeatureProvider: MLFeatureProvider {
    
    // MARK: - 프로퍼티
    /// 피처 이름 (모델 입력 이름)
    let featureName: String
    
    /// 이미지 데이터 (CVPixelBuffer)
    let pixelBuffer: CVPixelBuffer
    
    // MARK: - MLFeatureProvider 구현
    var featureNames: Set<String> {
        [featureName]
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        guard featureName == self.featureName else { return nil }
        return MLFeatureValue(pixelBuffer: pixelBuffer)
    }
    
    // MARK: - 초기화
    /// CVPixelBuffer로 초기화
    /// - Parameters:
    ///   - pixelBuffer: 이미지 픽셀 버퍼
    ///   - featureName: 피처 이름 (기본값: "image")
    init(pixelBuffer: CVPixelBuffer, featureName: String = "image") {
        self.pixelBuffer = pixelBuffer
        self.featureName = featureName
    }
    
    /// CIImage로 초기화
    /// - Parameters:
    ///   - ciImage: CIImage
    ///   - targetSize: 타겟 크기
    ///   - featureName: 피처 이름
    convenience init?(ciImage: CIImage, targetSize: CGSize, featureName: String = "image") {
        guard let pixelBuffer = ciImage.toPixelBuffer(size: targetSize) else {
            return nil
        }
        self.init(pixelBuffer: pixelBuffer, featureName: featureName)
    }
    
    #if canImport(UIKit)
    /// UIImage로 초기화
    /// - Parameters:
    ///   - image: UIImage
    ///   - targetSize: 타겟 크기
    ///   - featureName: 피처 이름
    convenience init?(image: UIImage, targetSize: CGSize, featureName: String = "image") {
        guard let ciImage = CIImage(image: image) else { return nil }
        self.init(ciImage: ciImage, targetSize: targetSize, featureName: featureName)
    }
    #elseif canImport(AppKit)
    /// NSImage로 초기화
    /// - Parameters:
    ///   - image: NSImage
    ///   - targetSize: 타겟 크기
    ///   - featureName: 피처 이름
    convenience init?(image: NSImage, targetSize: CGSize, featureName: String = "image") {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        self.init(ciImage: ciImage, targetSize: targetSize, featureName: featureName)
    }
    #endif
}

// MARK: - MLMultiArray 피처 제공자
/// 다차원 배열 입력을 위한 피처 제공자
final class MultiArrayFeatureProvider: MLFeatureProvider {
    
    // MARK: - 프로퍼티
    /// 피처들 (이름: MLMultiArray)
    private let features: [String: MLMultiArray]
    
    // MARK: - MLFeatureProvider 구현
    var featureNames: Set<String> {
        Set(features.keys)
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        guard let array = features[featureName] else { return nil }
        return MLFeatureValue(multiArray: array)
    }
    
    // MARK: - 초기화
    /// 딕셔너리로 초기화
    /// - Parameter features: 피처 딕셔너리
    init(features: [String: MLMultiArray]) {
        self.features = features
    }
    
    /// 단일 배열로 초기화
    /// - Parameters:
    ///   - array: MLMultiArray
    ///   - featureName: 피처 이름
    convenience init(array: MLMultiArray, featureName: String) {
        self.init(features: [featureName: array])
    }
}

// MARK: - MLMultiArray 생성 헬퍼
extension MLMultiArray {
    
    /// Float 배열로 1차원 MLMultiArray 생성
    /// - Parameter floats: Float 배열
    /// - Returns: MLMultiArray
    static func from1D(_ floats: [Float]) throws -> MLMultiArray {
        let array = try MLMultiArray(shape: [NSNumber(value: floats.count)], dataType: .float32)
        
        for (index, value) in floats.enumerated() {
            array[index] = NSNumber(value: value)
        }
        
        return array
    }
    
    /// Double 배열로 1차원 MLMultiArray 생성
    /// - Parameter doubles: Double 배열
    /// - Returns: MLMultiArray
    static func from1D(_ doubles: [Double]) throws -> MLMultiArray {
        let array = try MLMultiArray(shape: [NSNumber(value: doubles.count)], dataType: .double)
        
        for (index, value) in doubles.enumerated() {
            array[index] = NSNumber(value: value)
        }
        
        return array
    }
    
    /// 2차원 Float 배열로 MLMultiArray 생성
    /// - Parameter data: 2차원 Float 배열
    /// - Returns: MLMultiArray
    static func from2D(_ data: [[Float]]) throws -> MLMultiArray {
        guard !data.isEmpty, !data[0].isEmpty else {
            throw MultiArrayError.invalidDimensions
        }
        
        let rows = data.count
        let cols = data[0].count
        
        let array = try MLMultiArray(
            shape: [NSNumber(value: rows), NSNumber(value: cols)],
            dataType: .float32
        )
        
        for i in 0..<rows {
            for j in 0..<cols {
                array[[i, j] as [NSNumber]] = NSNumber(value: data[i][j])
            }
        }
        
        return array
    }
    
    /// 3차원 (CHW: 채널, 높이, 너비) 형태의 MLMultiArray 생성 (이미지용)
    /// - Parameters:
    ///   - channels: 채널 수
    ///   - height: 높이
    ///   - width: 너비
    ///   - dataType: 데이터 타입
    /// - Returns: 초기화된 MLMultiArray
    static func createImageArray(
        channels: Int,
        height: Int,
        width: Int,
        dataType: MLMultiArrayDataType = .float32
    ) throws -> MLMultiArray {
        try MLMultiArray(
            shape: [
                NSNumber(value: channels),
                NSNumber(value: height),
                NSNumber(value: width)
            ],
            dataType: dataType
        )
    }
    
    /// Float 배열로 변환
    /// - Returns: Float 배열
    func toFloatArray() -> [Float] {
        let count = self.count
        var result = [Float](repeating: 0, count: count)
        
        for i in 0..<count {
            result[i] = self[i].floatValue
        }
        
        return result
    }
    
    /// 최대값 인덱스 찾기
    /// - Returns: 최대값의 인덱스
    func argmax() -> Int? {
        guard count > 0 else { return nil }
        
        var maxIndex = 0
        var maxValue = self[0].floatValue
        
        for i in 1..<count {
            let value = self[i].floatValue
            if value > maxValue {
                maxValue = value
                maxIndex = i
            }
        }
        
        return maxIndex
    }
    
    /// Softmax 적용
    /// - Returns: Softmax가 적용된 배열
    func softmax() -> [Float] {
        let floats = toFloatArray()
        let maxVal = floats.max() ?? 0
        
        // 오버플로우 방지를 위해 최대값을 뺌
        let expValues = floats.map { exp($0 - maxVal) }
        let sumExp = expValues.reduce(0, +)
        
        return expValues.map { $0 / sumExp }
    }
}

/// MLMultiArray 오류
enum MultiArrayError: LocalizedError {
    case invalidDimensions
    case creationFailed
    case conversionFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidDimensions:
            return "유효하지 않은 배열 차원"
        case .creationFailed:
            return "MLMultiArray 생성 실패"
        case .conversionFailed:
            return "배열 변환 실패"
        }
    }
}

// MARK: - 예측 옵션 빌더
/// MLPredictionOptions를 쉽게 구성하기 위한 빌더
final class PredictionOptionsBuilder {
    
    private var options = MLPredictionOptions()
    
    /// 사용할 출력 백킹 제한
    /// - Parameter types: 허용할 백킹 타입 세트
    /// - Returns: 빌더 (체이닝용)
    @available(iOS 16.0, macOS 13.0, *)
    func outputBackings(_ types: MLPredictionOptions.OutputBackings) -> PredictionOptionsBuilder {
        options.outputBackings = types
        return self
    }
    
    /// 최종 옵션 반환
    /// - Returns: 구성된 MLPredictionOptions
    func build() -> MLPredictionOptions {
        return options
    }
    
    /// 기본 예측 옵션 생성
    static var `default`: MLPredictionOptions {
        MLPredictionOptions()
    }
    
    /// 성능 최적화 옵션 생성
    @available(iOS 16.0, macOS 13.0, *)
    static var optimized: MLPredictionOptions {
        let options = MLPredictionOptions()
        // 필요한 최적화 설정 추가
        return options
    }
}

// MARK: - 배치 피처 제공자
/// 여러 입력을 배치로 처리하기 위한 피처 제공자 (iOS 14+)
final class BatchFeatureProvider: MLBatchProvider {
    
    // MARK: - 프로퍼티
    private let providers: [MLFeatureProvider]
    
    // MARK: - MLBatchProvider 구현
    var count: Int {
        providers.count
    }
    
    func features(at index: Int) -> MLFeatureProvider {
        providers[index]
    }
    
    // MARK: - 초기화
    init(providers: [MLFeatureProvider]) {
        self.providers = providers
    }
    
    /// 이미지 배열로 초기화
    /// - Parameters:
    ///   - pixelBuffers: 픽셀 버퍼 배열
    ///   - featureName: 피처 이름
    convenience init(pixelBuffers: [CVPixelBuffer], featureName: String = "image") {
        let providers = pixelBuffers.map {
            ImageFeatureProvider(pixelBuffer: $0, featureName: featureName)
        }
        self.init(providers: providers)
    }
}

// MARK: - CIImage 확장
extension CIImage {
    
    /// CIImage를 CVPixelBuffer로 변환
    /// - Parameter size: 타겟 크기
    /// - Returns: 변환된 픽셀 버퍼
    func toPixelBuffer(size: CGSize) -> CVPixelBuffer? {
        let context = CIContext()
        
        // 이미지 리사이즈
        let scaleX = size.width / extent.width
        let scaleY = size.height / extent.height
        let scale = min(scaleX, scaleY)
        
        let scaledImage = transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        
        // 픽셀 버퍼 생성
        var pixelBuffer: CVPixelBuffer?
        let attrs: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ]
        
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(size.width),
            Int(size.height),
            kCVPixelFormatType_32BGRA,
            attrs as CFDictionary,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        // 이미지 렌더링
        context.render(scaledImage, to: buffer)
        
        return buffer
    }
}

// MARK: - 딕셔너리 피처 제공자
/// 딕셔너리 형태의 피처 입력을 위한 제공자
final class DictionaryFeatureProvider: MLFeatureProvider {
    
    // MARK: - 프로퍼티
    private let dictionary: [String: MLFeatureValue]
    
    // MARK: - MLFeatureProvider 구현
    var featureNames: Set<String> {
        Set(dictionary.keys)
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        dictionary[featureName]
    }
    
    // MARK: - 초기화
    init(_ dictionary: [String: MLFeatureValue]) {
        self.dictionary = dictionary
    }
    
    /// 간편 생성: String 값들
    static func with(strings: [String: String]) -> DictionaryFeatureProvider {
        var dict: [String: MLFeatureValue] = [:]
        for (key, value) in strings {
            dict[key] = MLFeatureValue(string: value)
        }
        return DictionaryFeatureProvider(dict)
    }
    
    /// 간편 생성: Int 값들
    static func with(ints: [String: Int]) -> DictionaryFeatureProvider {
        var dict: [String: MLFeatureValue] = [:]
        for (key, value) in ints {
            dict[key] = MLFeatureValue(int64: Int64(value))
        }
        return DictionaryFeatureProvider(dict)
    }
    
    /// 간편 생성: Double 값들
    static func with(doubles: [String: Double]) -> DictionaryFeatureProvider {
        var dict: [String: MLFeatureValue] = [:]
        for (key, value) in doubles {
            dict[key] = MLFeatureValue(double: value)
        }
        return DictionaryFeatureProvider(dict)
    }
}
