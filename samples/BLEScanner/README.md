# BLEScanner

CoreBluetooth를 사용한 Bluetooth Low Energy 기기 스캐너 앱입니다.

## 📱 기능

### 기기 스캔
- 주변 BLE 기기 실시간 스캔
- 신호 강도(RSSI) 기반 정렬
- 기기 이름, UUID 검색
- 오래된 기기 자동 제거

### 기기 연결
- BLE 기기 연결/해제
- 연결 상태 실시간 표시
- 자동 서비스 검색

### 서비스/특성 탐색
- 연결된 기기의 서비스 목록
- 각 서비스의 특성(Characteristic) 표시
- 표준 BLE 서비스/특성 이름 자동 인식

### 데이터 통신
- 특성 값 읽기
- 특성에 데이터 쓰기 (16진수)
- 알림(Notify) 구독/해제
- 실시간 값 업데이트

### 스캔 설정
- 중복 기기 허용 옵션
- 오래된 기기 제거 시간 설정
- 서비스 UUID 필터링
- 사전 정의 서비스 빠른 선택

## 📁 프로젝트 구조

```
BLEScanner/
├── Shared/                          # 공유 모델 및 매니저
│   ├── DiscoveredDevice.swift       # 발견된 기기 모델
│   ├── BluetoothManager.swift       # CBCentralManager 래퍼
│   └── DeviceConnection.swift       # 연결/데이터 교환 관리
│
├── BLEScannerApp/                   # SwiftUI 앱
│   ├── BLEScannerApp.swift          # @main 진입점
│   ├── ContentView.swift            # 메인 스캔 목록
│   ├── DeviceRowView.swift          # 기기 Row 컴포넌트
│   ├── DeviceDetailView.swift       # 기기 상세 (서비스/특성)
│   └── SettingsView.swift           # 스캔 설정
│
└── README.md
```

## 🔧 핵심 컴포넌트

### DiscoveredDevice
발견된 BLE 기기를 나타내는 모델입니다.

```swift
// 주요 프로퍼티
let id: UUID                    // 고유 식별자
let peripheral: CBPeripheral    // CoreBluetooth peripheral
var name: String                // 기기 이름
var rssi: Int                   // 신호 강도 (dBm)
var connectionState             // 연결 상태
var services: [CBService]       // 발견된 서비스
var characteristics: [CBUUID: [CBCharacteristic]]  // 서비스별 특성
```

### BluetoothManager
CoreBluetooth의 CBCentralManager를 래핑하는 싱글톤입니다.

```swift
// 스캔 제어
BluetoothManager.shared.startScanning()
BluetoothManager.shared.stopScanning()

// 연결 관리
BluetoothManager.shared.connect(to: device)
BluetoothManager.shared.disconnect(from: device)

// 설정
BluetoothManager.shared.allowDuplicates = true
BluetoothManager.shared.serviceUUIDFilter = [CBUUID(string: "180F")]
```

### DeviceConnection
연결된 기기와의 데이터 교환을 관리합니다.

```swift
// 특성 읽기/쓰기
DeviceConnection.shared.readValue(from: peripheral, characteristic: char)
DeviceConnection.shared.writeValue(to: peripheral, characteristic: char, data: data)

// 알림 설정
DeviceConnection.shared.setNotify(for: peripheral, characteristic: char, enabled: true)
```

## 📋 요구사항

- iOS 17.0+
- Xcode 15.0+
- 실제 iOS 기기 (시뮬레이터에서는 BLE 사용 불가)

## ⚙️ 설정

### Info.plist
Bluetooth 사용을 위해 다음 키를 추가해야 합니다:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>주변 BLE 기기를 스캔하고 연결하기 위해 Bluetooth 권한이 필요합니다.</string>
```

## 🎨 UI 구성

### ContentView (메인 화면)
- 상단: Bluetooth 상태 배너
- 중앙: 기기 목록 (검색, 정렬 지원)
- 하단: 스캔 시작/중지 버튼
- Pull-to-refresh로 재스캔

### DeviceDetailView (상세 화면)
- 기기 정보 섹션: UUID, RSSI, 연결 상태
- 연결 섹션: 연결/해제 버튼
- 서비스 섹션: 서비스 및 특성 트리 구조
- 각 특성별 읽기/쓰기/알림 버튼

### SettingsView (설정 화면)
- Bluetooth 상태 표시
- 스캔 옵션 (중복 허용, 타임아웃)
- 서비스 필터 설정

## 📊 신호 강도 해석

| RSSI (dBm) | 품질 | 색상 |
|------------|------|------|
| -30 ~ -50  | 매우 강함 | 🟢 녹색 |
| -50 ~ -70  | 양호 | 🔵 파란색 |
| -70 ~ -85  | 보통 | 🟠 주황색 |
| -85 이하   | 약함 | 🔴 빨간색 |

## 🔒 표준 BLE 서비스

앱에서 자동으로 인식하는 표준 서비스:

| UUID | 이름 |
|------|------|
| 180A | 기기 정보 |
| 180F | 배터리 |
| 180D | 심박수 |
| 1810 | 혈압 |
| 1809 | 체온계 |

## 📝 사용 예시

### 1. 기기 스캔
```
1. 앱 실행
2. Bluetooth 권한 허용
3. 재생 버튼(▶️) 탭하여 스캔 시작
4. 발견된 기기 목록 확인
```

### 2. 기기 연결
```
1. 목록에서 기기 탭
2. 상세 화면에서 "연결" 버튼 탭
3. 서비스 검색 대기
4. 서비스 확장하여 특성 확인
```

### 3. 데이터 읽기
```
1. 연결된 기기의 특성 찾기
2. "읽기" 버튼 탭
3. 값이 HEX와 UTF-8로 표시됨
```

### 4. 알림 구독
```
1. Notify 지원 특성 찾기
2. "알림" 버튼 탭
3. 기기가 데이터 전송 시 자동 업데이트
```

## 🐛 문제 해결

### "Bluetooth가 꺼져 있습니다"
→ 설정 > Bluetooth에서 활성화

### "권한 없음" 표시
→ 설정 > 개인정보 보호 > Bluetooth에서 앱 권한 허용

### 기기가 보이지 않음
→ 기기가 광고 모드인지 확인
→ 서비스 필터가 활성화되어 있는지 확인

### 연결 실패
→ 기기가 범위 내에 있는지 확인
→ 다른 앱/기기와 연결되어 있는지 확인

## 📚 참고 자료

- [Apple CoreBluetooth Documentation](https://developer.apple.com/documentation/corebluetooth)
- [Bluetooth SIG Assigned Numbers](https://www.bluetooth.com/specifications/assigned-numbers/)
- [GATT Services](https://www.bluetooth.com/specifications/gatt/services/)

---

**HIG Lab Sample Project** | SwiftUI + CoreBluetooth
