import CoreHaptics

// MARK: - 햅틱 지원 여부 확인

/// 현재 기기가 햅틱을 지원하는지 확인
func checkHapticCapability() -> Bool {
    // 하드웨어 지원 여부
    let supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
    
    if supportsHaptics {
        print("✅ 이 기기는 햅틱을 지원합니다.")
    } else {
        print("❌ 이 기기는 햅틱을 지원하지 않습니다.")
        print("실제 iPhone 8 이상의 디바이스에서 테스트하세요.")
    }
    
    return supportsHaptics
}

// MARK: - 지원 기기

/*
 Core Haptics 지원 기기:
 - iPhone 8 이상
 - Apple Watch (제한적 지원)
 
 지원하지 않는 환경:
 - iOS 시뮬레이터
 - iPhone 7 이하
 - iPad (대부분)
 */
