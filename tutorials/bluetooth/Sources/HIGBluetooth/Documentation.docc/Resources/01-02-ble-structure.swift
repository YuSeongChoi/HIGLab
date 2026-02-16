import CoreBluetooth

// BLE GATT (Generic Attribute Profile) 구조
//
// Peripheral (기기)
// └── Service (서비스) - 기능 그룹
//     └── Characteristic (특성) - 실제 데이터
//         └── Descriptor (설명자) - 메타데이터
//
// 예: 심박수 모니터
// └── Heart Rate Service (0x180D)
//     ├── Heart Rate Measurement (0x2A37) - 심박수 값
//     └── Body Sensor Location (0x2A38) - 센서 위치

// Service: 관련 기능의 묶음
// Characteristic: 읽기/쓰기/알림 가능한 데이터 단위
// Descriptor: Characteristic의 추가 정보 (예: 단위, 범위)
