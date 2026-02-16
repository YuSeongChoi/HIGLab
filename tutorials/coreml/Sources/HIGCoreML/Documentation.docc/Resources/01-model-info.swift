import Foundation

/// 사용할 CoreML 모델 정보
///
/// Apple Developer에서 MobileNetV2 다운로드:
/// https://developer.apple.com/machine-learning/models/
///
/// MobileNetV2는 ImageNet 데이터셋으로 훈련된
/// 1000개 클래스 이미지 분류 모델입니다.
struct ModelInfo {
    
    /// 모델 이름
    static let modelName = "MobileNetV2"
    
    /// 입력 이미지 크기 (224 × 224 픽셀)
    static let inputSize = CGSize(width: 224, height: 224)
    
    /// 출력 클래스 수 (1000개)
    static let numberOfClasses = 1000
    
    /// 모델 파일 크기 (약 14MB)
    static let fileSizeMB = 14.0
    
    /// 추론 시간 (iPhone 14 기준)
    /// - Neural Engine: ~3ms
    /// - GPU: ~5ms  
    /// - CPU: ~15ms
}

/*
 MobileNetV2 프로젝트 추가 방법:
 
 1. Apple Developer에서 MobileNetV2.mlmodel 다운로드
 2. Xcode 프로젝트 네비게이터로 드래그
 3. "Copy items if needed" 체크
 4. Target Membership 확인
 
 Xcode가 자동으로 MobileNetV2 Swift 클래스를 생성합니다!
 */
