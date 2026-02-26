# 🏠 SmartHome

스마트홈 컨트롤러 통합 샘플 프로젝트입니다.

## 사용 프레임워크

| 프레임워크 | 용도 |
|-----------|------|
| **SwiftUI** | 선언적 UI |
| **Core Bluetooth** | BLE 기기 스캔/연결 |
| **Wi-Fi Aware** | 직접 WiFi 연결 (iOS 26) |
| **AccessorySetupKit** | 액세서리 페어링 |
| **Core NFC** | NFC 태그 읽기/쓰기 |

## 주요 기능

- 📶 BLE 기기 스캔 (Core Bluetooth)
- 📡 P2P WiFi 연결 (Wi-Fi Aware)
- 🔗 액세서리 설정 (AccessorySetupKit)
- 📱 NFC 태그 제어 (Core NFC)

## 학습 포인트

1. **Core Bluetooth**: CBCentralManager, 기기 검색/연결
2. **Wi-Fi Aware**: AP 없이 직접 통신
3. **AccessorySetupKit**: 공식 액세서리 페어링 플로우
4. **Core NFC**: NDEF 읽기/쓰기
