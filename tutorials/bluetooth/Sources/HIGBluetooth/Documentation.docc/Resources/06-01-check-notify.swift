import CoreBluetooth

extension CBCharacteristic {
    // 알림 지원 여부 확인
    var supportsNotify: Bool {
        properties.contains(.notify)
    }
    
    var supportsIndicate: Bool {
        properties.contains(.indicate)
    }
    
    var supportsAnyNotification: Bool {
        supportsNotify || supportsIndicate
    }
}

// Characteristic 확인
func checkNotificationSupport(_ char: CBCharacteristic) {
    if char.supportsNotify {
        print("✅ Notify 지원")
    } else if char.supportsIndicate {
        print("✅ Indicate 지원 (신뢰성 높음)")
    } else {
        print("❌ 알림 미지원 - 폴링 필요")
    }
}
