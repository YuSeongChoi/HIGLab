import Foundation
import CoreML
import Vision
import CoreImage

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - 배치 처리기
// 여러 이미지를 효율적으로 배치 처리하는 유틸리티
// MLBatchProvider, MLFeatureProvider 활용

@MainActor
final class BatchProcessor: ObservableObject {
    
    // MARK: - Published 프로퍼티
    /// 처리 진행 상태
    @Published private(set) var isProcessing = false
    
    /// 현재 진행률 (0.0 ~ 1.0)
    @Published private(set) var progress: Double = 0
    
    /// 처리된 결과들
    @Published private(set) var results: [BatchItemResult] = []
    
    /// 현재 상태 메시지
    @Published private(set) var statusMessage = ""
    
    /// 총 처리 시간 (ms)
    @Published private(set) var totalProcessingTimeMs: Double = 0
    
    // MARK: - 설정
    /// 동시 처리 개수
    var concurrencyLimit: Int = 4
    
    /// 에러 발생 시 중단 여부
    var stopOnError: Bool = false
    
    // MARK: - Private 프로퍼티
    private let classifier: ImageClassifier
    private let detector: ObjectDetector
    private let analyzer: VisionAnalyzer
    
    // MARK: - 초기화
    init(
        classifier: ImageClassifier = ImageClassifier(),
        detector: ObjectDetector = ObjectDetector(),
        analyzer: VisionAnalyzer = VisionAnalyzer()
    ) {
        self.classifier = classifier
        self.detector = detector
        self.analyzer = analyzer
    }
    
    // MARK: - 배치 분류
    /// 여러 이미지 일괄 분류
    /// - Parameters:
    ///   - images: 분류할 이미지 배열
    ///   - modelType: 사용할 모델 타입
    /// - Returns: 각 이미지별 분류 결과
    func classifyBatch(
        _ images: [PlatformImage],
        modelType: MLModelType = .mobileNetV2
    ) async throws -> [BatchItemResult] {
        isProcessing = true
        progress = 0
        results = []
        statusMessage = "모델 준비 중..."
        
        defer {
            isProcessing = false
            progress = 1.0
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // 모델 준비
        try await classifier.prepareModel(modelType)
        
        statusMessage = "이미지 분류 중..."
        
        // 동시성 제한 처리
        var allResults: [BatchItemResult] = []
        
        for startIndex in stride(from: 0, to: images.count, by: concurrencyLimit) {
            let endIndex = min(startIndex + concurrencyLimit, images.count)
            let batch = Array(images[startIndex..<endIndex])
            
            // 배치 내 병렬 처리
            let batchResults = await withTaskGroup(of: BatchItemResult.self) { group in
                for (offset, image) in batch.enumerated() {
                    let index = startIndex + offset
                    
                    group.addTask {
                        do {
                            let classifications = try await self.classifier.classify(image: image)
                            return BatchItemResult(
                                index: index,
                                success: true,
                                classifications: classifications,
                                processingTimeMs: self.classifier.lastPredictionTimeMs
                            )
                        } catch {
                            return BatchItemResult(
                                index: index,
                                success: false,
                                error: error.localizedDescription
                            )
                        }
                    }
                }
                
                var results: [BatchItemResult] = []
                for await result in group {
                    results.append(result)
                }
                
                return results.sorted { $0.index < $1.index }
            }
            
            allResults.append(contentsOf: batchResults)
            progress = Double(endIndex) / Double(images.count)
            
            // 에러 시 중단 체크
            if stopOnError && batchResults.contains(where: { !$0.success }) {
                break
            }
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        totalProcessingTimeMs = (endTime - startTime) * 1000
        
        results = allResults
        statusMessage = "완료: \(allResults.filter { $0.success }.count)/\(images.count) 성공"
        
        return allResults
    }
    
    /// 여러 URL에서 이미지 로드 및 분류
    /// - Parameters:
    ///   - urls: 이미지 URL 배열
    ///   - modelType: 사용할 모델 타입
    /// - Returns: 각 이미지별 분류 결과
    func classifyBatch(
        from urls: [URL],
        modelType: MLModelType = .mobileNetV2
    ) async throws -> [BatchItemResult] {
        isProcessing = true
        progress = 0
        statusMessage = "이미지 로딩 중..."
        
        // URL에서 이미지 로드
        var images: [PlatformImage] = []
        
        for (index, url) in urls.enumerated() {
            do {
                let data: Data
                if url.isFileURL {
                    data = try Data(contentsOf: url)
                } else {
                    (data, _) = try await URLSession.shared.data(from: url)
                }
                
                #if canImport(UIKit)
                if let image = UIImage(data: data) {
                    images.append(image)
                }
                #elseif canImport(AppKit)
                if let image = NSImage(data: data) {
                    images.append(image)
                }
                #endif
                
                progress = Double(index + 1) / Double(urls.count) * 0.3
            } catch {
                print("이미지 로드 실패: \(url) - \(error)")
            }
        }
        
        // 분류 수행
        return try await classifyBatch(images, modelType: modelType)
    }
    
    // MARK: - 배치 분석
    /// 여러 이미지 일괄 분석 (텍스트 + 얼굴 + 포즈)
    /// - Parameter images: 분석할 이미지 배열
    /// - Returns: 각 이미지별 분석 결과
    func analyzeBatch(_ images: [PlatformImage]) async throws -> [BatchAnalysisResult] {
        isProcessing = true
        progress = 0
        statusMessage = "이미지 분석 중..."
        
        defer {
            isProcessing = false
            progress = 1.0
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        var allResults: [BatchAnalysisResult] = []
        
        for (index, image) in images.enumerated() {
            statusMessage = "분석 중... (\(index + 1)/\(images.count))"
            
            do {
                let result = try await analyzer.analyzeAll(in: image)
                
                allResults.append(BatchAnalysisResult(
                    index: index,
                    success: true,
                    analysisResult: result
                ))
            } catch {
                allResults.append(BatchAnalysisResult(
                    index: index,
                    success: false,
                    error: error.localizedDescription
                ))
                
                if stopOnError {
                    break
                }
            }
            
            progress = Double(index + 1) / Double(images.count)
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        totalProcessingTimeMs = (endTime - startTime) * 1000
        
        statusMessage = "완료: \(allResults.filter { $0.success }.count)/\(images.count) 성공"
        
        return allResults
    }
    
    // MARK: - 배치 객체 탐지
    /// 여러 이미지에서 일괄 객체 탐지
    /// - Parameters:
    ///   - images: 분석할 이미지 배열
    ///   - modelType: 사용할 모델 타입
    /// - Returns: 각 이미지별 탐지 결과
    func detectBatch(
        _ images: [PlatformImage],
        modelType: MLModelType = .yoloV3Tiny
    ) async throws -> [BatchDetectionResult] {
        isProcessing = true
        progress = 0
        statusMessage = "모델 준비 중..."
        
        defer {
            isProcessing = false
            progress = 1.0
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // 모델 준비
        try await detector.prepareModel(modelType)
        
        statusMessage = "객체 탐지 중..."
        
        var allResults: [BatchDetectionResult] = []
        
        for (index, image) in images.enumerated() {
            do {
                let objects = try await detector.detect(in: image)
                
                allResults.append(BatchDetectionResult(
                    index: index,
                    success: true,
                    detectedObjects: objects,
                    processingTimeMs: detector.lastInferenceTimeMs
                ))
            } catch {
                allResults.append(BatchDetectionResult(
                    index: index,
                    success: false,
                    error: error.localizedDescription
                ))
                
                if stopOnError {
                    break
                }
            }
            
            progress = Double(index + 1) / Double(images.count)
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        totalProcessingTimeMs = (endTime - startTime) * 1000
        
        statusMessage = "완료: \(allResults.filter { $0.success }.count)/\(images.count) 성공"
        
        return allResults
    }
    
    /// 결과 초기화
    func clearResults() {
        results = []
        progress = 0
        totalProcessingTimeMs = 0
        statusMessage = ""
    }
}

// MARK: - 배치 처리 결과
/// 단일 배치 아이템 결과 (분류)
struct BatchItemResult: Identifiable {
    let id = UUID()
    let index: Int
    let success: Bool
    var classifications: [ClassificationResult] = []
    var error: String?
    var processingTimeMs: Double = 0
    
    /// 최상위 분류 결과
    var topClassification: ClassificationResult? {
        classifications.first
    }
}

/// 단일 배치 아이템 결과 (분석)
struct BatchAnalysisResult: Identifiable {
    let id = UUID()
    let index: Int
    let success: Bool
    var analysisResult: AnalysisResult?
    var error: String?
}

/// 단일 배치 아이템 결과 (탐지)
struct BatchDetectionResult: Identifiable {
    let id = UUID()
    let index: Int
    let success: Bool
    var detectedObjects: [DetectedObject] = []
    var error: String?
    var processingTimeMs: Double = 0
}

// MARK: - 배치 결과 통계
extension Array where Element == BatchItemResult {
    
    /// 성공 개수
    var successCount: Int {
        filter { $0.success }.count
    }
    
    /// 실패 개수
    var failureCount: Int {
        filter { !$0.success }.count
    }
    
    /// 평균 처리 시간 (성공한 항목만)
    var averageProcessingTimeMs: Double {
        let successResults = filter { $0.success }
        guard !successResults.isEmpty else { return 0 }
        
        let total = successResults.reduce(0) { $0 + $1.processingTimeMs }
        return total / Double(successResults.count)
    }
    
    /// 가장 많이 나온 분류 결과
    var mostCommonLabel: String? {
        let allLabels = flatMap { $0.classifications.map { $0.label } }
        let grouped = Dictionary(grouping: allLabels) { $0 }
        
        return grouped.max { $0.value.count < $1.value.count }?.key
    }
    
    /// 요약 통계
    var summary: String {
        """
        === 배치 처리 요약 ===
        총 처리: \(count)개
        성공: \(successCount)개
        실패: \(failureCount)개
        평균 처리 시간: \(String(format: "%.2f", averageProcessingTimeMs))ms
        가장 흔한 분류: \(mostCommonLabel ?? "없음")
        """
    }
}
