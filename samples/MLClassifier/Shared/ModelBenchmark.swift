import Foundation
import CoreML
import Vision
import CoreImage

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - 모델 벤치마크
// CoreML 모델의 성능을 측정하고 비교하는 유틸리티
// MLModel, MLPredictionOptions, MLComputeUnits 활용

@MainActor
final class ModelBenchmark: ObservableObject {
    
    // MARK: - Published 프로퍼티
    /// 벤치마크 진행 상태
    @Published private(set) var isRunning = false
    
    /// 현재 진행률 (0.0 ~ 1.0)
    @Published private(set) var progress: Double = 0
    
    /// 벤치마크 결과들
    @Published private(set) var results: [BenchmarkResult] = []
    
    /// 현재 상태 메시지
    @Published private(set) var statusMessage = ""
    
    // MARK: - 설정
    /// 워밍업 반복 횟수
    var warmupIterations: Int = 5
    
    /// 측정 반복 횟수
    var measureIterations: Int = 20
    
    /// 테스트 이미지 크기
    var testImageSize: CGSize = CGSize(width: 224, height: 224)
    
    // MARK: - 초기화
    init() {}
    
    // MARK: - 벤치마크 실행
    /// 단일 모델 벤치마크
    /// - Parameters:
    ///   - modelType: 테스트할 모델 타입
    ///   - computeUnits: 연산 장치
    /// - Returns: 벤치마크 결과
    func benchmark(
        modelType: MLModelType,
        computeUnits: ComputeUnitOption = .all
    ) async throws -> BenchmarkResult {
        isRunning = true
        progress = 0
        statusMessage = "\(modelType.rawValue) 모델 로딩 중..."
        
        defer {
            isRunning = false
            progress = 1.0
        }
        
        // 모델 로드
        let modelManager = MLModelManager.shared
        guard let model = await modelManager.loadModel(
            modelType,
            computeUnits: computeUnits,
            useCache: false
        ) else {
            throw BenchmarkError.modelLoadFailed
        }
        
        // Vision 모델로 변환
        let visionModel = try VNCoreMLModel(for: model)
        
        // 테스트 이미지 생성
        let testImage = createTestImage(size: testImageSize)
        
        // 워밍업
        statusMessage = "워밍업 중..."
        for i in 0..<warmupIterations {
            _ = try await performInference(
                visionModel: visionModel,
                image: testImage
            )
            progress = Double(i + 1) / Double(warmupIterations + measureIterations)
        }
        
        // 측정
        statusMessage = "성능 측정 중..."
        var times: [Double] = []
        
        for i in 0..<measureIterations {
            let time = try await measureInferenceTime(
                visionModel: visionModel,
                image: testImage
            )
            times.append(time)
            progress = Double(warmupIterations + i + 1) /
                       Double(warmupIterations + measureIterations)
        }
        
        // 통계 계산
        let result = calculateStatistics(
            times: times,
            modelType: modelType,
            computeUnits: computeUnits
        )
        
        statusMessage = "완료"
        results.append(result)
        
        return result
    }
    
    /// 여러 모델 비교 벤치마크
    /// - Parameters:
    ///   - modelTypes: 테스트할 모델 타입들
    ///   - computeUnits: 연산 장치
    /// - Returns: 벤치마크 결과 배열
    func compareModels(
        _ modelTypes: [MLModelType],
        computeUnits: ComputeUnitOption = .all
    ) async throws -> [BenchmarkResult] {
        var allResults: [BenchmarkResult] = []
        
        for (index, modelType) in modelTypes.enumerated() {
            statusMessage = "[\(index + 1)/\(modelTypes.count)] \(modelType.rawValue) 테스트 중..."
            
            do {
                let result = try await benchmark(
                    modelType: modelType,
                    computeUnits: computeUnits
                )
                allResults.append(result)
            } catch {
                print("벤치마크 실패: \(modelType.rawValue) - \(error)")
            }
        }
        
        return allResults
    }
    
    /// 다양한 연산 장치로 벤치마크
    /// - Parameter modelType: 테스트할 모델 타입
    /// - Returns: 각 연산 장치별 결과
    func benchmarkComputeUnits(
        for modelType: MLModelType
    ) async throws -> [BenchmarkResult] {
        var allResults: [BenchmarkResult] = []
        
        let units: [ComputeUnitOption] = [.all, .cpuAndGPU, .cpuAndNeuralEngine, .cpuOnly]
        
        for (index, unit) in units.enumerated() {
            statusMessage = "[\(index + 1)/\(units.count)] \(unit.rawValue) 테스트 중..."
            
            do {
                let result = try await benchmark(
                    modelType: modelType,
                    computeUnits: unit
                )
                allResults.append(result)
            } catch {
                print("벤치마크 실패: \(unit.rawValue) - \(error)")
            }
        }
        
        return allResults
    }
    
    /// 결과 초기화
    func clearResults() {
        results = []
    }
    
    // MARK: - Private 헬퍼
    /// 테스트 이미지 생성
    private func createTestImage(size: CGSize) -> CGImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: Int(size.width) * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else {
            fatalError("테스트 이미지 생성 실패")
        }
        
        // 랜덤 노이즈 이미지 생성
        let data = context.data!
        let buffer = data.bindMemory(to: UInt8.self, capacity: Int(size.width * size.height) * 4)
        
        for i in 0..<Int(size.width * size.height * 4) {
            buffer[i] = UInt8.random(in: 0...255)
        }
        
        return context.makeImage()!
    }
    
    /// 추론 수행
    private func performInference(
        visionModel: VNCoreMLModel,
        image: CGImage
    ) async throws -> [VNClassificationObservation] {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNCoreMLRequest(model: visionModel) { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let observations = request.results as? [VNClassificationObservation] ?? []
                continuation.resume(returning: observations)
            }
            
            request.imageCropAndScaleOption = .centerCrop
            
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    /// 추론 시간 측정
    private func measureInferenceTime(
        visionModel: VNCoreMLModel,
        image: CGImage
    ) async throws -> Double {
        let startTime = CFAbsoluteTimeGetCurrent()
        _ = try await performInference(visionModel: visionModel, image: image)
        let endTime = CFAbsoluteTimeGetCurrent()
        
        return (endTime - startTime) * 1000 // ms
    }
    
    /// 통계 계산
    private func calculateStatistics(
        times: [Double],
        modelType: MLModelType,
        computeUnits: ComputeUnitOption
    ) -> BenchmarkResult {
        let sorted = times.sorted()
        
        // 평균
        let average = times.reduce(0, +) / Double(times.count)
        
        // 최소/최대
        let min = sorted.first ?? 0
        let max = sorted.last ?? 0
        
        // 표준편차
        let variance = times.map { pow($0 - average, 2) }.reduce(0, +) / Double(times.count)
        let stdDev = sqrt(variance)
        
        return BenchmarkResult(
            modelType: modelType,
            computeUnits: computeUnits,
            averageInferenceTimeMs: average,
            minInferenceTimeMs: min,
            maxInferenceTimeMs: max,
            standardDeviationMs: stdDev,
            iterations: times.count
        )
    }
}

// MARK: - 벤치마크 오류
enum BenchmarkError: LocalizedError {
    case modelLoadFailed
    case inferenceFailed(String)
    case invalidTestImage
    
    var errorDescription: String? {
        switch self {
        case .modelLoadFailed:
            return "모델을 로드할 수 없습니다"
        case .inferenceFailed(let reason):
            return "추론 실패: \(reason)"
        case .invalidTestImage:
            return "테스트 이미지를 생성할 수 없습니다"
        }
    }
}

// MARK: - 벤치마크 결과 비교
extension Array where Element == BenchmarkResult {
    
    /// 가장 빠른 결과
    var fastest: BenchmarkResult? {
        self.min { $0.averageInferenceTimeMs < $1.averageInferenceTimeMs }
    }
    
    /// 가장 느린 결과
    var slowest: BenchmarkResult? {
        self.max { $0.averageInferenceTimeMs < $1.averageInferenceTimeMs }
    }
    
    /// 평균 추론 시간 순으로 정렬
    var sortedBySpeed: [BenchmarkResult] {
        sorted { $0.averageInferenceTimeMs < $1.averageInferenceTimeMs }
    }
    
    /// 비교 요약 생성
    var comparisonSummary: String {
        guard !isEmpty else { return "결과 없음" }
        
        var summary = "=== 벤치마크 비교 ===\n\n"
        
        for (index, result) in sortedBySpeed.enumerated() {
            let rank = index + 1
            let speedup = fastest.map {
                result.averageInferenceTimeMs / $0.averageInferenceTimeMs
            } ?? 1.0
            
            summary += """
            #\(rank) \(result.modelType.rawValue) (\(result.computeUnits.rawValue))
               평균: \(String(format: "%.2f", result.averageInferenceTimeMs))ms
               FPS: \(String(format: "%.1f", result.fps))
               상대 속도: \(String(format: "%.2f", speedup))x
            
            """
        }
        
        return summary
    }
}
