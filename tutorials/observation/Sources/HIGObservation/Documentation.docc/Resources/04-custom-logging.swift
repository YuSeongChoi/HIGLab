import Foundation
import Observation

/// 커스텀 로깅 시스템
/// withObservationTracking을 활용해 상태 변화를 자동 기록합니다.

@Observable
class ObservableLogger {
    private(set) var logs: [LogEntry] = []
    
    struct LogEntry: Identifiable {
        let id = UUID()
        let timestamp: Date
        let message: String
    }
    
    func log(_ message: String) {
        logs.append(LogEntry(timestamp: Date(), message: message))
    }
    
    func clear() {
        logs.removeAll()
    }
}

/// 상태 변화 자동 로깅을 위한 도우미
class StateObserver<T: Observable> {
    private let target: T
    private let logger: ObservableLogger
    private var isObserving = true
    
    init(target: T, logger: ObservableLogger) {
        self.target = target
        self.logger = logger
        startObserving()
    }
    
    private func startObserving() {
        guard isObserving else { return }
        
        withObservationTracking {
            // Mirror를 사용해 모든 프로퍼티 접근
            let mirror = Mirror(reflecting: self.target)
            for child in mirror.children {
                _ = child.value  // 프로퍼티 접근 → 추적 등록
            }
        } onChange: {
            self.logger.log("[\(type(of: self.target))] 상태 변경됨")
            
            // 재등록
            DispatchQueue.main.async {
                self.startObserving()
            }
        }
    }
    
    func stopObserving() {
        isObserving = false
    }
}

// 사용 예시
func demonstrateLogging() {
    let cart = CartStore()
    let logger = ObservableLogger()
    
    let observer = StateObserver(target: cart, logger: logger)
    
    // 상태 변경 시 자동으로 로그 기록
    cart.addProduct(Product(name: "MacBook", price: 2_000_000))
    // 로그: "[CartStore] 상태 변경됨"
    
    cart.clearCart()
    // 로그: "[CartStore] 상태 변경됨"
    
    observer.stopObserving()
}
