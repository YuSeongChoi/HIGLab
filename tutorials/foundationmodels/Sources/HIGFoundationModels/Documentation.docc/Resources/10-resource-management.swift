import FoundationModels
import SwiftUI
import Combine

// 배터리 상태를 고려한 적응형 AI
@MainActor
class AdaptiveAIManager: ObservableObject {
    @Published var aiMode: AIMode = .full
    @Published var isLowPowerMode = false
    
    enum AIMode {
        case full        // 전체 기능
        case efficient   // 효율 모드 (짧은 응답)
        case minimal     // 최소 기능
        
        var maxResponseTokens: Int {
            switch self {
            case .full: return 500
            case .efficient: return 200
            case .minimal: return 100
            }
        }
        
        var systemPromptSuffix: String {
            switch self {
            case .full: return ""
            case .efficient: return "\n응답은 간결하게 해주세요."
            case .minimal: return "\n핵심만 1-2문장으로 답하세요."
            }
        }
    }
    
    private var batteryObserver: AnyCancellable?
    
    init() {
        observeBatteryState()
    }
    
    private func observeBatteryState() {
        // iOS에서 배터리 상태 모니터링
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        batteryObserver = NotificationCenter.default.publisher(
            for: UIDevice.batteryLevelDidChangeNotification
        )
        .sink { [weak self] _ in
            self?.updateAIMode()
        }
        
        // 초기 설정
        updateAIMode()
    }
    
    private func updateAIMode() {
        let batteryLevel = UIDevice.current.batteryLevel
        let batteryState = UIDevice.current.batteryState
        
        // 충전 중이면 전체 기능
        if batteryState == .charging || batteryState == .full {
            aiMode = .full
            return
        }
        
        // 배터리 레벨에 따라 모드 조정
        switch batteryLevel {
        case 0.5...:
            aiMode = .full
        case 0.2..<0.5:
            aiMode = .efficient
        default:
            aiMode = .minimal
        }
        
        // 저전력 모드 확인
        isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
        if isLowPowerMode {
            aiMode = .minimal
        }
    }
    
    func createOptimizedSession(basePrompt: String) -> LanguageModel.Session {
        let prompt = basePrompt + aiMode.systemPromptSuffix
        return LanguageModel.default.createSession(systemPrompt: prompt)
    }
}

// 메모리 압박 대응
class MemoryAwareAI {
    private var session: LanguageModel.Session?
    
    init() {
        // 메모리 경고 알림 구독
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    @objc private func handleMemoryWarning() {
        // 캐시된 세션 해제
        session = nil
        
        // 필요시 다시 생성
        print("메모리 부족으로 AI 세션 해제됨")
    }
}
