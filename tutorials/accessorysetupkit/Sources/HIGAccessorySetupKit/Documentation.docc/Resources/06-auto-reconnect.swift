import CoreBluetooth
import os.log

class AutoReconnectManager {
    private var centralManager: CBCentralManager!
    private var targetPeripheral: CBPeripheral?
    private var reconnectAttempts = 0
    private let maxAttempts = 5
    
    private let logger = Logger(subsystem: "com.app", category: "Reconnect")
    
    // 지수 백오프 재연결
    func handleDisconnection(peripheral: CBPeripheral, error: Error?) {
        logger.info("연결 해제됨: \(peripheral.identifier)")
        
        guard reconnectAttempts < maxAttempts else {
            logger.error("최대 재시도 횟수 초과")
            notifyConnectionFailed()
            return
        }
        
        // 지수 백오프 딜레이 계산
        let delay = pow(2.0, Double(reconnectAttempts))
        reconnectAttempts += 1
        
        logger.info("재연결 시도 #\(self.reconnectAttempts), \(delay)초 후")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.attemptReconnect(peripheral: peripheral)
        }
    }
    
    private func attemptReconnect(peripheral: CBPeripheral) {
        guard centralManager.state == .poweredOn else {
            logger.warning("Bluetooth 꺼짐, 대기 중")
            return
        }
        
        targetPeripheral = peripheral
        centralManager.connect(peripheral, options: [
            CBConnectPeripheralOptionNotifyOnDisconnectionKey: true
        ])
    }
    
    func connectionSucceeded() {
        reconnectAttempts = 0
        logger.info("재연결 성공")
    }
    
    private func notifyConnectionFailed() {
        NotificationCenter.default.post(
            name: .accessoryConnectionFailed,
            object: nil
        )
    }
}

extension Notification.Name {
    static let accessoryConnectionFailed = Notification.Name("accessoryConnectionFailed")
}
