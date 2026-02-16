import CoreML

/// MLModelConfiguration 활용
///
/// 컴퓨팅 유닛, 메모리 제약 등을 설정할 수 있습니다.
struct ModelConfigurationExamples {
    
    /// 기본 설정 (모든 하드웨어 자동 선택)
    func defaultConfiguration() -> MLModelConfiguration {
        let config = MLModelConfiguration()
        config.computeUnits = .all  // Neural Engine > GPU > CPU 우선순위
        return config
    }
    
    /// Neural Engine + CPU만 사용 (GPU 제외)
    func cpuAndNeuralEngineOnly() -> MLModelConfiguration {
        let config = MLModelConfiguration()
        config.computeUnits = .cpuAndNeuralEngine
        return config
    }
    
    /// CPU만 사용 (디버깅/테스트용)
    func cpuOnly() -> MLModelConfiguration {
        let config = MLModelConfiguration()
        config.computeUnits = .cpuOnly
        return config
    }
    
    /// GPU만 사용
    func gpuOnly() -> MLModelConfiguration {
        let config = MLModelConfiguration()
        config.computeUnits = .cpuAndGPU
        // GPU가 없으면 CPU로 폴백
        return config
    }
    
    /// iOS 17+: 함수 이름으로 특정 함수만 로드
    @available(iOS 17, macOS 14, *)
    func loadSpecificFunction() -> MLModelConfiguration {
        let config = MLModelConfiguration()
        config.functionName = "main"  // 멀티 함수 모델에서 특정 함수만 로드
        return config
    }
}

/*
 ComputeUnits 선택 가이드:
 
 .all (기본값)
 - 최적의 성능을 위해 자동 선택
 - 대부분의 경우 권장
 
 .cpuAndNeuralEngine  
 - GPU를 다른 작업에 양보하고 싶을 때
 - 배터리 효율이 중요할 때
 
 .cpuOnly
 - 디버깅/테스트
 - GPU/Neural Engine에서 문제가 있을 때
 - 결과 재현성이 필요할 때
 */
