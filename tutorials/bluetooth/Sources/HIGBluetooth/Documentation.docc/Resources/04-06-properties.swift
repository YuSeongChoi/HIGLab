import CoreBluetooth

// CBCharacteristicProperties 분석
extension CBCharacteristicProperties {
    var description: String {
        var props: [String] = []
        
        if contains(.read) { props.append("Read") }
        if contains(.write) { props.append("Write") }
        if contains(.writeWithoutResponse) { props.append("WriteNoResponse") }
        if contains(.notify) { props.append("Notify") }
        if contains(.indicate) { props.append("Indicate") }
        if contains(.broadcast) { props.append("Broadcast") }
        
        return props.joined(separator: ", ")
    }
}

// 사용 예시
func analyzeCharacteristic(_ char: CBCharacteristic) {
    print("UUID: \(char.uuid)")
    print("Properties: \(char.properties.description)")
    
    // 각 속성 확인
    let canRead = char.properties.contains(.read)
    let canWrite = char.properties.contains(.write)
    let canNotify = char.properties.contains(.notify)
    
    print("읽기: \(canRead), 쓰기: \(canWrite), 알림: \(canNotify)")
}
