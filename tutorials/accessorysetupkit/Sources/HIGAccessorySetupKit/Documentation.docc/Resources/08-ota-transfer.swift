import CoreBluetooth
import os.log

class OTAUpdateManager {
    private let peripheral: CBPeripheral
    private let otaCharacteristic: CBCharacteristic
    private let chunkSize = 20 // BLE MTU 기반
    private let logger = Logger(subsystem: "com.app", category: "OTA")
    
    var onProgress: ((Double) -> Void)?
    var onComplete: ((Result<Void, Error>) -> Void)?
    
    init(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        self.peripheral = peripheral
        self.otaCharacteristic = characteristic
    }
    
    // 펌웨어 전송 시작
    func startUpdate(with firmwareData: Data) async throws {
        logger.info("OTA 업데이트 시작: \(firmwareData.count) bytes")
        
        // 업데이트 시작 명령 전송
        try await sendCommand(.startUpdate(size: firmwareData.count))
        
        // 청크 단위로 분할
        let chunks = firmwareData.chunked(into: chunkSize)
        let totalChunks = chunks.count
        
        for (index, chunk) in chunks.enumerated() {
            try await sendChunk(chunk, index: index)
            
            let progress = Double(index + 1) / Double(totalChunks)
            onProgress?(progress)
            
            // 전송 속도 조절
            try await Task.sleep(for: .milliseconds(50))
        }
        
        // 전송 완료 명령
        try await sendCommand(.finishUpdate)
        logger.info("OTA 전송 완료")
    }
    
    private func sendChunk(_ data: Data, index: Int) async throws {
        var packet = Data()
        packet.append(UInt8(index & 0xFF))
        packet.append(UInt8((index >> 8) & 0xFF))
        packet.append(data)
        
        peripheral.writeValue(packet, for: otaCharacteristic, type: .withResponse)
        // 응답 대기는 delegate에서 처리
    }
    
    private func sendCommand(_ command: OTACommand) async throws {
        peripheral.writeValue(command.data, for: otaCharacteristic, type: .withResponse)
    }
}

enum OTACommand {
    case startUpdate(size: Int)
    case finishUpdate
    case reboot
    
    var data: Data {
        switch self {
        case .startUpdate(let size):
            var d = Data([0x01])
            d.append(contentsOf: withUnsafeBytes(of: UInt32(size)) { Array($0) })
            return d
        case .finishUpdate:
            return Data([0x02])
        case .reboot:
            return Data([0x03])
        }
    }
}

extension Data {
    func chunked(into size: Int) -> [Data] {
        stride(from: 0, to: count, by: size).map {
            self[$0 ..< Swift.min($0 + size, count)]
        }
    }
}
