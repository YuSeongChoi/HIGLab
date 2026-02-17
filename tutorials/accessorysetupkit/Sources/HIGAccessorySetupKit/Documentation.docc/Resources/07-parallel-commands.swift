import Foundation

// 여러 액세서리에 병렬로 명령 전송
@MainActor
class ParallelCommandExecutor {
    private let connectionActor = AccessoryConnectionActor()
    
    // TaskGroup을 사용한 병렬 명령 실행
    func sendCommandToAll(_ command: Data) async -> [UUID: Result<Data, Error>] {
        let accessoryIDs = await connectionActor.getAllConnectedIDs()
        
        return await withTaskGroup(of: (UUID, Result<Data, Error>).self) { group in
            for id in accessoryIDs {
                group.addTask {
                    do {
                        let response = try await self.sendCommand(command, to: id)
                        return (id, .success(response))
                    } catch {
                        return (id, .failure(error))
                    }
                }
            }
            
            var results: [UUID: Result<Data, Error>] = [:]
            for await (id, result) in group {
                results[id] = result
            }
            return results
        }
    }
    
    // 개별 액세서리에 명령 전송
    private func sendCommand(_ command: Data, to accessoryID: UUID) async throws -> Data {
        guard let peripheral = await connectionActor.getPeripheral(for: accessoryID) else {
            throw AccessoryError.notConnected
        }
        
        // 실제 BLE 특성에 쓰기
        return try await withCheckedThrowingContinuation { continuation in
            // CBPeripheral writeValue 호출
            // 응답은 delegate에서 continuation.resume으로 전달
        }
    }
    
    // 모든 기기 상태 동시 조회
    func queryAllStatus() async -> [UUID: DeviceStatus] {
        let statusCommand = Data([0x01, 0x00]) // 상태 조회 명령
        let results = await sendCommandToAll(statusCommand)
        
        var statuses: [UUID: DeviceStatus] = [:]
        for (id, result) in results {
            if case .success(let data) = result {
                statuses[id] = DeviceStatus(from: data)
            }
        }
        return statuses
    }
}

enum AccessoryError: Error {
    case notConnected
    case timeout
    case invalidResponse
}

struct DeviceStatus {
    let batteryLevel: Int
    let isActive: Bool
    
    init(from data: Data) {
        batteryLevel = Int(data[0])
        isActive = data[1] == 1
    }
}
