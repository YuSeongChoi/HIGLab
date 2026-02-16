import CoreBluetooth

// BLE 통신의 두 가지 역할

// 1. Central (중앙 장치)
// - 스캔을 시작하여 주변 기기를 찾음
// - 연결을 요청함
// - 데이터를 읽고/쓰고/알림을 구독함
// - 예: iPhone 앱, Mac 앱

// 2. Peripheral (주변 장치)
// - 자신의 존재를 광고(Advertise)함
// - Central의 연결을 기다림
// - 서비스와 데이터를 제공함
// - 예: 심박수 밴드, 스마트 조명, BLE 센서

// iOS 앱은 두 역할 모두 수행 가능
// - CBCentralManager: Central 역할
// - CBPeripheralManager: Peripheral 역할
