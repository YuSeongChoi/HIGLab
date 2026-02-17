import AccessorySetupKit
import UIKit

// 피커에 표시할 액세서리 아이템 구성
func createPickerDisplayItem() -> ASPickerDisplayItem {
    // Discovery Descriptor 생성
    let descriptor = ASDiscoveryDescriptor()
    descriptor.bluetoothServiceUUID = CBUUID(string: "180D")
    
    // 피커 아이템 생성
    let displayItem = ASPickerDisplayItem(
        name: "스마트 센서",
        productImage: UIImage(named: "sensor-icon")!,
        descriptor: descriptor
    )
    
    return displayItem
}

// 여러 액세서리 타입을 위한 아이템 배열
func createPickerItems() -> [ASPickerDisplayItem] {
    let sensorDescriptor = ASDiscoveryDescriptor()
    sensorDescriptor.bluetoothServiceUUID = CBUUID(string: "180D")
    
    let hubDescriptor = ASDiscoveryDescriptor()
    hubDescriptor.ssidPrefix = "SmartHub_"
    
    return [
        ASPickerDisplayItem(
            name: "온도 센서",
            productImage: UIImage(systemName: "thermometer")!,
            descriptor: sensorDescriptor
        ),
        ASPickerDisplayItem(
            name: "스마트 허브",
            productImage: UIImage(systemName: "wifi")!,
            descriptor: hubDescriptor
        )
    ]
}
