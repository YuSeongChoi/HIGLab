import Foundation

struct HeartRateMeasurement {
    let heartRate: Int
    let contactDetected: Bool?
    let energyExpended: Int?
    let rrIntervals: [Double]
}

// Bluetooth SIG Heart Rate Profile 파싱
func parseHeartRate(data: Data) -> HeartRateMeasurement? {
    guard !data.isEmpty else { return nil }
    
    let flags = data[0]
    var offset = 1
    
    // 비트 0: 심박수 형식 (0=UInt8, 1=UInt16)
    let is16Bit = (flags & 0x01) != 0
    
    // 심박수 읽기
    let heartRate: Int
    if is16Bit {
        guard data.count >= offset + 2 else { return nil }
        heartRate = Int(data.readUInt16(at: offset) ?? 0)
        offset += 2
    } else {
        heartRate = Int(data[offset])
        offset += 1
    }
    
    // 비트 1-2: 센서 접촉 상태
    let contactDetected: Bool? = (flags & 0x04) != 0 
        ? (flags & 0x02) != 0 
        : nil
    
    // 비트 3: 에너지 소비량 존재
    let energyExpended: Int? = (flags & 0x08) != 0 && data.count >= offset + 2
        ? Int(data.readUInt16(at: offset) ?? 0)
        : nil
    
    return HeartRateMeasurement(
        heartRate: heartRate,
        contactDetected: contactDetected,
        energyExpended: energyExpended,
        rrIntervals: []
    )
}
