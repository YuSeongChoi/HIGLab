// Info.plist 필수 설정

/*
 AccessorySetupKit 사용을 위한 필수 권한 설정:
 
 1. Bluetooth 권한 (필수)
 - NSBluetoothAlwaysUsageDescription
   "기기와 연결하기 위해 Bluetooth가 필요합니다."
 
 - NSBluetoothPeripheralUsageDescription (iOS 13 이하 호환)
   "기기와 연결하기 위해 Bluetooth가 필요합니다."
 
 2. 로컬 네트워크 권한 (Wi-Fi 액세서리용)
 - NSLocalNetworkUsageDescription
   "같은 네트워크의 기기를 찾기 위해 필요합니다."
 
 - NSBonjourServices
   ["_myaccessory._tcp"]
 
 3. 백그라운드 모드 (선택사항)
 - UIBackgroundModes
   ["bluetooth-central", "bluetooth-peripheral"]
 
 4. AccessorySetupKit 설정
 - NSAccessorySetupKitSupports
   ["Bluetooth", "WiFi"]
   
 - NSAccessorySetupBluetoothServices (권장)
   서비스 UUID 배열로 허용된 Bluetooth 서비스 지정
*/

// Info.plist XML 예시
let infoPlistContent = """
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSBluetoothAlwaysUsageDescription</key>
    <string>스마트 기기와 연결하기 위해 Bluetooth 권한이 필요합니다.</string>
    
    <key>NSLocalNetworkUsageDescription</key>
    <string>같은 Wi-Fi에 연결된 기기를 찾기 위해 필요합니다.</string>
    
    <key>NSAccessorySetupKitSupports</key>
    <array>
        <string>Bluetooth</string>
        <string>WiFi</string>
    </array>
    
    <key>UIBackgroundModes</key>
    <array>
        <string>bluetooth-central</string>
    </array>
</dict>
</plist>
"""
