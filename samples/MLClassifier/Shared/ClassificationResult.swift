import Foundation
import Vision

// MARK: - 분류 결과 모델
// 이미지 분류, 객체 탐지, 텍스트 인식 등의 결과를 담는 구조체들

/// 단일 분류 결과
struct ClassificationResult: Identifiable, Hashable, Codable {
    
    // MARK: - 프로퍼티
    let id: UUID
    
    /// 분류 라벨 (예: "golden retriever", "tabby cat")
    let label: String
    
    /// 신뢰도 (0.0 ~ 1.0)
    let confidence: Float
    
    /// Vision 요청 리비전 (디버깅용)
    let requestRevision: Int?
    
    /// 분류 시간
    let timestamp: Date
    
    // MARK: - 초기화
    init(
        id: UUID = UUID(),
        label: String,
        confidence: Float,
        requestRevision: Int? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.label = label
        self.confidence = confidence
        self.requestRevision = requestRevision
        self.timestamp = timestamp
    }
    
    // MARK: - 계산 프로퍼티
    /// 신뢰도를 퍼센트 문자열로 변환
    var confidencePercentage: String {
        String(format: "%.1f%%", confidence * 100)
    }
    
    /// 상세 신뢰도 문자열 (소수점 3자리)
    var confidenceDetailedString: String {
        String(format: "%.3f", confidence)
    }
    
    /// 신뢰도 레벨 (UI 표시용)
    var confidenceLevel: ConfidenceLevel {
        switch confidence {
        case 0.8...1.0:
            return .high
        case 0.5..<0.8:
            return .medium
        case 0.2..<0.5:
            return .low
        default:
            return .veryLow
        }
    }
    
    /// 라벨을 사용자 친화적으로 포맷
    var formattedLabel: String {
        label
            .replacingOccurrences(of: "_", with: " ")
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ClassificationResult, rhs: ClassificationResult) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 신뢰도 레벨
enum ConfidenceLevel: String, CaseIterable, Codable {
    case high = "높음"       // 80% 이상
    case medium = "중간"     // 50% ~ 80%
    case low = "낮음"        // 20% ~ 50%
    case veryLow = "매우 낮음" // 20% 미만
    
    /// 레벨에 따른 색상명
    var colorName: String {
        switch self {
        case .high: return "green"
        case .medium: return "orange"
        case .low: return "yellow"
        case .veryLow: return "red"
        }
    }
    
    /// 아이콘 이름
    var iconName: String {
        switch self {
        case .high: return "checkmark.circle.fill"
        case .medium: return "circle.fill"
        case .low: return "exclamationmark.circle.fill"
        case .veryLow: return "xmark.circle.fill"
        }
    }
}

// MARK: - 분류 상태
/// 분류 작업의 현재 상태
enum ClassificationState: Equatable {
    case idle           // 대기 중
    case loading        // 모델 로딩 중
    case classifying    // 분류 진행 중
    case success([ClassificationResult])  // 분류 완료
    case failure(String) // 오류 발생
    
    /// 상태 설명
    var description: String {
        switch self {
        case .idle:
            return "준비됨"
        case .loading:
            return "모델 로딩 중..."
        case .classifying:
            return "분류 중..."
        case .success(let results):
            return "완료 (\(results.count)개 결과)"
        case .failure(let message):
            return "오류: \(message)"
        }
    }
    
    /// 진행 중 여부
    var isInProgress: Bool {
        switch self {
        case .loading, .classifying:
            return true
        default:
            return false
        }
    }
    
    static func == (lhs: ClassificationState, rhs: ClassificationState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.classifying, .classifying):
            return true
        case (.success(let l), .success(let r)):
            return l == r
        case (.failure(let l), .failure(let r)):
            return l == r
        default:
            return false
        }
    }
}

// MARK: - 객체 탐지 결과
/// 단일 객체 탐지 결과
struct DetectedObject: Identifiable, Hashable {
    let id = UUID()
    
    /// 객체 라벨
    let label: String
    
    /// 신뢰도
    let confidence: Float
    
    /// 바운딩 박스 (정규화된 좌표: 0~1)
    let boundingBox: CGRect
    
    /// VNClassificationObservation들 (세부 분류)
    let labels: [VNClassificationObservation]?
    
    // MARK: - 초기화
    init(
        label: String,
        confidence: Float,
        boundingBox: CGRect,
        labels: [VNClassificationObservation]? = nil
    ) {
        self.label = label
        self.confidence = confidence
        self.boundingBox = boundingBox
        self.labels = labels
    }
    
    /// VNRecognizedObjectObservation에서 생성
    init?(from observation: VNRecognizedObjectObservation, minimumConfidence: Float = 0.1) {
        guard let topLabel = observation.labels.first,
              topLabel.confidence >= minimumConfidence else {
            return nil
        }
        
        self.label = topLabel.identifier
        self.confidence = topLabel.confidence
        self.boundingBox = observation.boundingBox
        self.labels = observation.labels
    }
    
    // MARK: - 계산 프로퍼티
    /// 신뢰도 퍼센트 문자열
    var confidencePercentage: String {
        String(format: "%.1f%%", confidence * 100)
    }
    
    /// 화면 좌표로 변환된 바운딩 박스
    func screenBoundingBox(in viewSize: CGSize) -> CGRect {
        // Vision 좌표계 (좌하단 원점)를 화면 좌표계 (좌상단 원점)로 변환
        CGRect(
            x: boundingBox.origin.x * viewSize.width,
            y: (1 - boundingBox.origin.y - boundingBox.height) * viewSize.height,
            width: boundingBox.width * viewSize.width,
            height: boundingBox.height * viewSize.height
        )
    }
    
    /// 바운딩 박스 중심점
    var center: CGPoint {
        CGPoint(
            x: boundingBox.midX,
            y: boundingBox.midY
        )
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: DetectedObject, rhs: DetectedObject) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 텍스트 인식 결과
/// 인식된 텍스트 결과
struct RecognizedText: Identifiable, Hashable {
    let id = UUID()
    
    /// 인식된 텍스트
    let text: String
    
    /// 신뢰도
    let confidence: Float
    
    /// 텍스트 영역 (정규화된 좌표)
    let boundingBox: CGRect
    
    /// VNRecognizedTextObservation에서 생성
    init(text: String, confidence: Float, boundingBox: CGRect) {
        self.text = text
        self.confidence = confidence
        self.boundingBox = boundingBox
    }
    
    /// 화면 좌표로 변환된 영역
    func screenBoundingBox(in viewSize: CGSize) -> CGRect {
        CGRect(
            x: boundingBox.origin.x * viewSize.width,
            y: (1 - boundingBox.origin.y - boundingBox.height) * viewSize.height,
            width: boundingBox.width * viewSize.width,
            height: boundingBox.height * viewSize.height
        )
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: RecognizedText, rhs: RecognizedText) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 얼굴 감지 결과
/// 감지된 얼굴 정보
struct DetectedFace: Identifiable, Hashable {
    let id = UUID()
    
    /// 얼굴 영역 (정규화된 좌표)
    let boundingBox: CGRect
    
    /// 얼굴 회전 각도 (라디안)
    let roll: CGFloat?
    
    /// 얼굴 기울기 각도 (라디안)
    let yaw: CGFloat?
    
    /// 랜드마크 (눈, 코, 입 등)
    let landmarks: VNFaceLandmarks2D?
    
    /// VNFaceObservation에서 생성
    init(from observation: VNFaceObservation) {
        self.boundingBox = observation.boundingBox
        self.roll = observation.roll?.doubleValue
        self.yaw = observation.yaw?.doubleValue
        self.landmarks = observation.landmarks
    }
    
    /// 화면 좌표로 변환된 영역
    func screenBoundingBox(in viewSize: CGSize) -> CGRect {
        CGRect(
            x: boundingBox.origin.x * viewSize.width,
            y: (1 - boundingBox.origin.y - boundingBox.height) * viewSize.height,
            width: boundingBox.width * viewSize.width,
            height: boundingBox.height * viewSize.height
        )
    }
    
    /// 얼굴 회전 각도 (도)
    var rollDegrees: CGFloat? {
        guard let roll = roll else { return nil }
        return roll * 180 / .pi
    }
    
    /// 얼굴 기울기 각도 (도)
    var yawDegrees: CGFloat? {
        guard let yaw = yaw else { return nil }
        return yaw * 180 / .pi
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: DetectedFace, rhs: DetectedFace) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 포즈 감지 결과
/// 인체 포즈 감지 결과
struct DetectedPose: Identifiable, Hashable {
    let id = UUID()
    
    /// 관절점들
    let joints: [VNHumanBodyPoseObservation.JointName: CGPoint]
    
    /// 신뢰도 맵
    let confidences: [VNHumanBodyPoseObservation.JointName: Float]
    
    /// VNHumanBodyPoseObservation에서 생성
    init?(from observation: VNHumanBodyPoseObservation) {
        guard let points = try? observation.recognizedPoints(.all) else {
            return nil
        }
        
        var joints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
        var confidences: [VNHumanBodyPoseObservation.JointName: Float] = [:]
        
        for (jointName, point) in points {
            // 신뢰도가 0.1 이상인 관절만 포함
            guard point.confidence > 0.1 else { continue }
            
            joints[jointName] = CGPoint(
                x: point.location.x,
                y: 1 - point.location.y  // Y축 반전
            )
            confidences[jointName] = point.confidence
        }
        
        self.joints = joints
        self.confidences = confidences
    }
    
    /// 특정 관절의 화면 좌표
    func screenPoint(for joint: VNHumanBodyPoseObservation.JointName, in viewSize: CGSize) -> CGPoint? {
        guard let point = joints[joint] else { return nil }
        
        return CGPoint(
            x: point.x * viewSize.width,
            y: point.y * viewSize.height
        )
    }
    
    /// 모든 관절 연결선 (스켈레톤)
    var connections: [(VNHumanBodyPoseObservation.JointName, VNHumanBodyPoseObservation.JointName)] {
        [
            // 몸통
            (.neck, .root),
            (.root, .leftHip),
            (.root, .rightHip),
            
            // 왼쪽 팔
            (.neck, .leftShoulder),
            (.leftShoulder, .leftElbow),
            (.leftElbow, .leftWrist),
            
            // 오른쪽 팔
            (.neck, .rightShoulder),
            (.rightShoulder, .rightElbow),
            (.rightElbow, .rightWrist),
            
            // 왼쪽 다리
            (.leftHip, .leftKnee),
            (.leftKnee, .leftAnkle),
            
            // 오른쪽 다리
            (.rightHip, .rightKnee),
            (.rightKnee, .rightAnkle)
        ]
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: DetectedPose, rhs: DetectedPose) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 벤치마크 결과
/// 모델 벤치마크 결과
struct BenchmarkResult: Identifiable {
    let id = UUID()
    
    /// 모델 타입
    let modelType: MLModelType
    
    /// 연산 장치
    let computeUnits: ComputeUnitOption
    
    /// 평균 추론 시간 (ms)
    let averageInferenceTimeMs: Double
    
    /// 최소 추론 시간 (ms)
    let minInferenceTimeMs: Double
    
    /// 최대 추론 시간 (ms)
    let maxInferenceTimeMs: Double
    
    /// 표준 편차 (ms)
    let standardDeviationMs: Double
    
    /// 테스트 횟수
    let iterations: Int
    
    /// 초당 추론 횟수 (FPS)
    var fps: Double {
        guard averageInferenceTimeMs > 0 else { return 0 }
        return 1000 / averageInferenceTimeMs
    }
    
    /// 요약 문자열
    var summary: String {
        """
        모델: \(modelType.rawValue)
        연산 장치: \(computeUnits.rawValue)
        평균: \(String(format: "%.2f", averageInferenceTimeMs))ms
        범위: \(String(format: "%.2f", minInferenceTimeMs)) - \(String(format: "%.2f", maxInferenceTimeMs))ms
        표준편차: \(String(format: "%.2f", standardDeviationMs))ms
        FPS: \(String(format: "%.1f", fps))
        """
    }
}
