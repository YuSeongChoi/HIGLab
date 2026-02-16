import CoreML

/// CoreML 아키텍처 개요
///
/// CoreML은 자동으로 최적의 하드웨어를 선택합니다:
/// - Neural Engine: A11 이상 칩에 탑재된 전용 ML 가속기
/// - GPU: 병렬 연산에 최적화
/// - CPU: 범용 연산, 폴백 옵션
///
/// 개발자는 하드웨어를 신경 쓰지 않아도 됩니다!
struct CoreMLArchitecture {
    
    /// 지원하는 모델 형식
    /// - .mlmodel: Apple 네이티브 형식
    /// - TensorFlow, PyTorch, ONNX 등에서 변환 가능
    let supportedFormats = [
        ".mlmodel",      // 네이티브 CoreML
        ".mlpackage",    // ML 프로그램 (iOS 15+)
    ]
    
    /// Apple Silicon 칩별 Neural Engine 성능
    /// A11 (iPhone 8/X): 0.6 TOPS
    /// A14 (iPhone 12): 11 TOPS  
    /// A17 Pro (iPhone 15 Pro): 35 TOPS
    /// M3 (Mac): 18 TOPS
}

/*
 ┌─────────────────────────────────────────────┐
 │              Your Swift App                │
 ├─────────────────────────────────────────────┤
 │              CoreML Framework              │
 ├─────────────────────────────────────────────┤
 │   Neural Engine  │    GPU    │    CPU      │
 └─────────────────────────────────────────────┘
 */
