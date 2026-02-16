import CoreBluetooth

// BLE UUID 종류

// 1. 표준 UUID (16비트) - Bluetooth SIG 정의
// 심박수 서비스
let heartRateServiceUUID = CBUUID(string: "180D")
// 배터리 서비스
let batteryServiceUUID = CBUUID(string: "180F")
// 기기 정보 서비스
let deviceInfoServiceUUID = CBUUID(string: "180A")

// 2. 커스텀 UUID (128비트) - 개발자 정의
// uuidgen 명령으로 생성
let customServiceUUID = CBUUID(string: "12345678-1234-5678-1234-56789ABCDEF0")
let customCharacteristicUUID = CBUUID(string: "12345678-1234-5678-1234-56789ABCDEF1")

// 표준 Characteristic UUID
let heartRateMeasurementUUID = CBUUID(string: "2A37")
let batteryLevelUUID = CBUUID(string: "2A19")
