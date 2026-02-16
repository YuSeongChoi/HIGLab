import Foundation

@Observable
class BluetoothManager {
    private var heartRateContinuation: AsyncStream<Int>.Continuation?
    
    // AsyncStream으로 심박수 스트리밍
    var heartRateStream: AsyncStream<Int> {
        AsyncStream { continuation in
            self.heartRateContinuation = continuation
            
            continuation.onTermination = { _ in
                // 구독 해제 로직
            }
        }
    }
    
    // 알림 수신 시 호출
    private func emitHeartRate(_ value: Int) {
        heartRateContinuation?.yield(value)
    }
}

// 사용 예
// Task {
//     for await heartRate in manager.heartRateStream {
//         print("Heart Rate: \(heartRate)")
//     }
// }
