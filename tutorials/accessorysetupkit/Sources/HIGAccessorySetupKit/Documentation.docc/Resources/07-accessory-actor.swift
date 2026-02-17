import CoreBluetooth
import os.log

// Actor를 사용한 동시성 안전한 액세서리 관리
actor AccessoryConnectionActor {
    private var connections: [UUID: CBPeripheral] = [:]
    private let logger = Logger(subsystem: "com.app", category: "AccessoryActor")
    
    func connect(_ peripheral: CBPeripheral, for accessoryID: UUID) {
        connections[accessoryID] = peripheral
        logger.info("연결 등록: \(accessoryID)")
    }
    
    func disconnect(accessoryID: UUID) -> CBPeripheral? {
        logger.info("연결 해제: \(accessoryID)")
        return connections.removeValue(forKey: accessoryID)
    }
    
    func getPeripheral(for accessoryID: UUID) -> CBPeripheral? {
        connections[accessoryID]
    }
    
    func getAllConnectedIDs() -> [UUID] {
        Array(connections.keys)
    }
    
    func isConnected(_ accessoryID: UUID) -> Bool {
        connections[accessoryID] != nil
    }
    
    // 모든 연결 상태 확인
    func connectionStatus() -> [(UUID, CBPeripheralState)] {
        connections.map { ($0.key, $0.value.state) }
    }
}

// 사용 예시
@MainActor
class AccessoryCoordinator {
    private let connectionActor = AccessoryConnectionActor()
    
    func connectAccessory(_ accessory: AccessoryStore.StoredAccessory,
                          peripheral: CBPeripheral) async {
        await connectionActor.connect(peripheral, for: accessory.id)
    }
    
    func disconnectAccessory(_ accessory: AccessoryStore.StoredAccessory) async {
        if let peripheral = await connectionActor.disconnect(accessoryID: accessory.id) {
            // 연결 해제 처리
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
}
