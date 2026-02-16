import CoreBluetooth
import Combine

@Observable
class BluetoothManager {
    var currentHeartRate: Int = 0
    var heartRateHistory: [Int] = []
    
    // didUpdateValueFor에서 호출
    private func handleHeartRateNotification(_ data: Data) {
        guard let measurement = parseHeartRate(data: data) else { return }
        
        // UI 업데이트
        currentHeartRate = measurement.heartRate
        heartRateHistory.append(measurement.heartRate)
        
        // 최근 100개만 유지
        if heartRateHistory.count > 100 {
            heartRateHistory.removeFirst()
        }
        
        print("💓 심박수 알림: \(measurement.heartRate) BPM")
    }
}

// didUpdateValueFor에서
// switch characteristic.uuid {
// case CBUUID(string: "2A37"):
//     handleHeartRateNotification(data)
// ...
// }
