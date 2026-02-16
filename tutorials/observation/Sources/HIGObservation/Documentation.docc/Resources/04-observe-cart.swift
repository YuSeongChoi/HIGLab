import Foundation
import Observation

/// CartStore의 변화를 감시하는 Observer
class CartObserver {
    private let cart: CartStore
    private let debug: DebugStore
    private var isActive = true
    
    // 이전 상태 추적
    private var previousCount: Int = 0
    private var previousTotal: Double = 0
    
    init(cart: CartStore, debug: DebugStore = .shared) {
        self.cart = cart
        self.debug = debug
        self.previousCount = cart.totalCount
        self.previousTotal = cart.totalPrice
        
        startObserving()
    }
    
    private func startObserving() {
        guard isActive else { return }
        
        withObservationTracking {
            // 추적할 프로퍼티들 접근
            _ = self.cart.items.count
            _ = self.cart.totalCount
            _ = self.cart.totalPrice
        } onChange: {
            self.handleChange()
            
            // 재등록
            DispatchQueue.main.async {
                self.startObserving()
            }
        }
    }
    
    private func handleChange() {
        let newCount = cart.totalCount
        let newTotal = cart.totalPrice
        
        // 어떤 변화가 있었는지 분석
        if newCount != previousCount {
            let diff = newCount - previousCount
            if diff > 0 {
                debug.logCartAction("상품 \(diff)개 추가됨 (총 \(newCount)개)")
            } else {
                debug.logCartAction("상품 \(-diff)개 제거됨 (총 \(newCount)개)")
            }
        }
        
        if newTotal != previousTotal {
            let formatted = newTotal.formatted(.currency(code: "KRW"))
            debug.logCartAction("총 금액 변경: \(formatted)")
        }
        
        // 상태 업데이트
        previousCount = newCount
        previousTotal = newTotal
    }
    
    func stop() {
        isActive = false
    }
}

// MARK: - CartStore Extension

extension CartStore {
    /// 디버그 관찰자 시작
    @discardableResult
    func startDebugObserver() -> CartObserver {
        CartObserver(cart: self)
    }
}
