// Info.plist에 추가할 키
//
// iOS 13+: Bluetooth 사용 권한
// Key: NSBluetoothAlwaysUsageDescription
// Value: "심박수 밴드와 연결하여 운동 데이터를 측정합니다."
//
// iOS 13 미만 (deprecated)
// Key: NSBluetoothPeripheralUsageDescription
//
// 백그라운드 모드 (필요시)
// Key: UIBackgroundModes
// Value: ["bluetooth-central", "bluetooth-peripheral"]

/*
 <key>NSBluetoothAlwaysUsageDescription</key>
 <string>BLE 기기와 연결하여 데이터를 주고받습니다.</string>
 
 <key>UIBackgroundModes</key>
 <array>
     <string>bluetooth-central</string>
 </array>
 */
