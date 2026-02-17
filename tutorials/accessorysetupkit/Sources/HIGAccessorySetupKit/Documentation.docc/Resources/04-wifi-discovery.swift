import AccessorySetupKit

// Wi-Fi 액세서리 Discovery Descriptor 설정
func createWiFiDescriptor() -> ASDiscoveryDescriptor {
    let descriptor = ASDiscoveryDescriptor()
    
    // SSID 접두사로 필터링
    descriptor.ssidPrefix = "MyAccessory_"
    
    // 또는 정확한 SSID 매칭
    // descriptor.ssid = "MyAccessory_001"
    
    return descriptor
}

// Bluetooth + Wi-Fi 복합 검색
func createCombinedDescriptor() -> ASDiscoveryDescriptor {
    let descriptor = ASDiscoveryDescriptor()
    
    descriptor.bluetoothServiceUUID = CBUUID(string: "FFF0")
    descriptor.ssidPrefix = "SmartHome_"
    
    return descriptor
}
