# AccessorySetupKit AI Reference

> 액세서리 연결 및 설정 가이드. 이 문서를 읽고 AccessorySetupKit 코드를 생성할 수 있습니다.

## 개요

AccessorySetupKit은 iOS 18+에서 제공하는 Bluetooth/Wi-Fi 액세서리 페어링 프레임워크입니다.
시스템 UI를 통해 사용자 친화적인 액세서리 발견, 페어링, 설정 경험을 제공합니다.
기존 CoreBluetooth보다 간편하고 보안성 높은 연결을 지원합니다.

## 필수 Import

```swift
import AccessorySetupKit
```

## 프로젝트 설정

### 1. Info.plist

```xml
<!-- Bluetooth 권한 -->
<key>NSBluetoothAlwaysUsageDescription</key>
<string>액세서리를 연결하기 위해 Bluetooth가 필요합니다.</string>

<!-- 로컬 네트워크 (Wi-Fi 액세서리) -->
<key>NSLocalNetworkUsageDescription</key>
<string>Wi-Fi 액세서리를 찾기 위해 로컬 네트워크 접근이 필요합니다.</string>

<!-- Bonjour 서비스 -->
<key>NSBonjourServices</key>
<array>
    <string>_myaccessory._tcp</string>
</array>
```

### 2. Capability
- Wireless Accessory Configuration (필요 시)

## 핵심 구성요소

### 1. ASAccessorySession (세션)

```swift
import AccessorySetupKit

// 세션 생성
let session = ASAccessorySession()

// 이벤트 핸들러
session.eventHandler = { event in
    switch event {
    case .accessoryAdded(let accessory):
        print("액세서리 추가됨: \(accessory.displayName)")
    case .accessoryRemoved(let accessory):
        print("액세서리 제거됨: \(accessory.displayName)")
    case .accessoryChanged(let accessory):
        print("액세서리 변경됨: \(accessory.displayName)")
    case .activated:
        print("세션 활성화됨")
    case .invalidated(let error):
        print("세션 무효화됨: \(error?.localizedDescription ?? "")")
    @unknown default:
        break
    }
}

// 세션 활성화
session.activate(on: DispatchQueue.main)
```

### 2. ASPickerDisplayItem (피커 항목)

```swift
// Bluetooth 액세서리
let bluetoothItem = ASPickerDisplayItem(
    name: "My Smart Device",
    productImage: UIImage(named: "device-icon")!,
    descriptor: ASDiscoveryDescriptor(bluetoothServiceUUID: CBUUID(string: "180A"))
)

// Wi-Fi 액세서리
let wifiItem = ASPickerDisplayItem(
    name: "Smart Home Hub",
    productImage: UIImage(named: "hub-icon")!,
    descriptor: ASDiscoveryDescriptor(
        ssid: ASDiscoveryDescriptor.ssidPrefix("SmartHub-"),
        supportedOptions: .ssidPrefix
    )
)
```

### 3. ASAccessory (연결된 액세서리)

```swift
// 연결된 액세서리 정보
let accessory: ASAccessory

accessory.displayName          // 표시 이름
accessory.state               // 연결 상태
accessory.bluetoothIdentifier // Bluetooth UUID
accessory.ssid                // Wi-Fi SSID
```

## 전체 작동 예제

```swift
import SwiftUI
import AccessorySetupKit
import CoreBluetooth

// MARK: - Accessory Manager
@Observable
class AccessoryManager {
    var accessories: [ASAccessory] = []
    var isSessionActive = false
    var isShowingPicker = false
    var errorMessage: String?
    
    private var session: ASAccessorySession?
    
    var isSupported: Bool {
        ASAccessorySession.isSupported
    }
    
    func activateSession() {
        session = ASAccessorySession()
        
        session?.eventHandler = { [weak self] event in
            DispatchQueue.main.async {
                self?.handleEvent(event)
            }
        }
        
        session?.activate(on: .main)
    }
    
    private func handleEvent(_ event: ASAccessoryEvent) {
        switch event {
        case .activated:
            isSessionActive = true
            // 이미 페어링된 액세서리 로드
            loadPairedAccessories()
            
        case .invalidated(let error):
            isSessionActive = false
            if let error = error {
                errorMessage = error.localizedDescription
            }
            
        case .accessoryAdded(let accessory):
            if !accessories.contains(where: { $0.bluetoothIdentifier == accessory.bluetoothIdentifier }) {
                accessories.append(accessory)
            }
            
        case .accessoryRemoved(let accessory):
            accessories.removeAll { $0.bluetoothIdentifier == accessory.bluetoothIdentifier }
            
        case .accessoryChanged(let accessory):
            if let index = accessories.firstIndex(where: { $0.bluetoothIdentifier == accessory.bluetoothIdentifier }) {
                accessories[index] = accessory
            }
            
        @unknown default:
            break
        }
    }
    
    private func loadPairedAccessories() {
        // 이전에 페어링된 액세서리 복원
        accessories = session?.accessories ?? []
    }
    
    // MARK: - 액세서리 검색 및 추가
    func showAccessoryPicker() {
        guard let session = session else { return }
        
        // 검색할 액세서리 정의
        let items = [
            // Bluetooth 장치
            ASPickerDisplayItem(
                name: "스마트 센서",
                productImage: UIImage(systemName: "sensor.fill")!,
                descriptor: ASDiscoveryDescriptor(
                    bluetoothServiceUUID: CBUUID(string: "180A")
                )
            ),
            // 커스텀 Bluetooth 서비스
            ASPickerDisplayItem(
                name: "피트니스 밴드",
                productImage: UIImage(systemName: "figure.run")!,
                descriptor: ASDiscoveryDescriptor(
                    bluetoothServiceUUID: CBUUID(string: "180D"),  // Heart Rate
                    bluetoothCompanyIdentifier: ASDiscoveryDescriptor.bluetoothCompanyIdentifierApple
                )
            )
        ]
        
        // 피커 표시
        session.showPicker(for: items) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "피커 오류: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // MARK: - 액세서리 제거
    func removeAccessory(_ accessory: ASAccessory) {
        session?.removeAccessory(accessory) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "제거 실패: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // MARK: - 액세서리 이름 변경
    func renameAccessory(_ accessory: ASAccessory, to newName: String) {
        session?.renameAccessory(accessory, to: newName) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "이름 변경 실패: \(error.localizedDescription)"
                }
            }
        }
    }
    
    deinit {
        session?.invalidate()
    }
}

// MARK: - Main View
struct AccessorySetupView: View {
    @State private var manager = AccessoryManager()
    @State private var showingRenameSheet = false
    @State private var accessoryToRename: ASAccessory?
    @State private var newName = ""
    
    var body: some View {
        NavigationStack {
            Group {
                if !manager.isSupported {
                    ContentUnavailableView(
                        "지원되지 않음",
                        systemImage: "antenna.radiowaves.left.and.right.slash",
                        description: Text("이 기기에서는 AccessorySetupKit을 사용할 수 없습니다")
                    )
                } else if !manager.isSessionActive {
                    VStack(spacing: 20) {
                        ProgressView()
                        Text("세션 활성화 중...")
                    }
                } else if manager.accessories.isEmpty {
                    ContentUnavailableView(
                        "연결된 액세서리 없음",
                        systemImage: "antenna.radiowaves.left.and.right",
                        description: Text("새 액세서리를 추가하세요")
                    )
                } else {
                    List {
                        ForEach(manager.accessories, id: \.displayName) { accessory in
                            AccessoryRow(accessory: accessory)
                                .contextMenu {
                                    Button {
                                        accessoryToRename = accessory
                                        newName = accessory.displayName
                                        showingRenameSheet = true
                                    } label: {
                                        Label("이름 변경", systemImage: "pencil")
                                    }
                                    
                                    Button(role: .destructive) {
                                        manager.removeAccessory(accessory)
                                    } label: {
                                        Label("제거", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
            .navigationTitle("액세서리")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        manager.showAccessoryPicker()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(!manager.isSessionActive)
                }
            }
            .alert("오류", isPresented: Binding(
                get: { manager.errorMessage != nil },
                set: { if !$0 { manager.errorMessage = nil } }
            )) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(manager.errorMessage ?? "")
            }
            .sheet(isPresented: $showingRenameSheet) {
                RenameSheet(
                    name: $newName,
                    onSave: {
                        if let accessory = accessoryToRename {
                            manager.renameAccessory(accessory, to: newName)
                        }
                        showingRenameSheet = false
                    },
                    onCancel: {
                        showingRenameSheet = false
                    }
                )
            }
            .task {
                manager.activateSession()
            }
        }
    }
}

// MARK: - Accessory Row
struct AccessoryRow: View {
    let accessory: ASAccessory
    
    var body: some View {
        HStack(spacing: 16) {
            // 아이콘
            Image(systemName: iconForAccessory)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 44, height: 44)
                .background(.blue.opacity(0.1), in: Circle())
            
            // 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(accessory.displayName)
                    .font(.headline)
                
                HStack {
                    Circle()
                        .fill(stateColor)
                        .frame(width: 8, height: 8)
                    Text(stateText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // 연결 타입 표시
            if accessory.bluetoothIdentifier != nil {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    var iconForAccessory: String {
        // 액세서리 타입에 따른 아이콘
        if accessory.displayName.lowercased().contains("sensor") {
            return "sensor.fill"
        } else if accessory.displayName.lowercased().contains("band") {
            return "figure.run"
        } else {
            return "antenna.radiowaves.left.and.right"
        }
    }
    
    var stateColor: Color {
        switch accessory.state {
        case .connected: return .green
        case .connecting: return .orange
        case .disconnected: return .red
        @unknown default: return .gray
        }
    }
    
    var stateText: String {
        switch accessory.state {
        case .connected: return "연결됨"
        case .connecting: return "연결 중..."
        case .disconnected: return "연결 안 됨"
        @unknown default: return "알 수 없음"
        }
    }
}

// MARK: - Rename Sheet
struct RenameSheet: View {
    @Binding var name: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("액세서리 이름", text: $name)
            }
            .navigationTitle("이름 변경")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장", action: onSave)
                        .disabled(name.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    AccessorySetupView()
}
```

## 고급 패턴

### 1. 액세서리 마이그레이션 (CoreBluetooth → AccessorySetupKit)

```swift
import CoreBluetooth
import AccessorySetupKit

class AccessoryMigrationManager {
    let session = ASAccessorySession()
    
    func migrateExistingAccessory(peripheral: CBPeripheral) {
        // 기존 CoreBluetooth 페어링을 AccessorySetupKit으로 마이그레이션
        let migrationItem = ASMigrationDisplayItem(
            name: peripheral.name ?? "Unknown Device",
            productImage: UIImage(systemName: "antenna.radiowaves.left.and.right")!,
            descriptor: ASDiscoveryDescriptor(
                bluetoothServiceUUID: CBUUID(string: "180A")
            )
        )
        
        session.showPicker(for: [migrationItem]) { error in
            if let error = error {
                print("마이그레이션 실패: \(error)")
            }
        }
    }
}
```

### 2. Wi-Fi 액세서리 설정

```swift
func setupWiFiAccessory() {
    let wifiItem = ASPickerDisplayItem(
        name: "Smart Home Hub",
        productImage: UIImage(named: "hub")!,
        descriptor: ASDiscoveryDescriptor(
            ssid: ASDiscoveryDescriptor.ssidPrefix("SmartHub-"),
            supportedOptions: .ssidPrefix
        )
    )
    
    // Wi-Fi 자격 증명 설정 (선택적)
    wifiItem.setupAssistant = { accessory, completion in
        // 사용자에게 Wi-Fi 비밀번호 입력 요청
        // 또는 프로비저닝 프로토콜 실행
        completion(.success)
    }
    
    session.showPicker(for: [wifiItem]) { error in
        // 처리
    }
}
```

### 3. Matter 디바이스 통합

```swift
import HomeKit
import AccessorySetupKit

class MatterSetupManager {
    let session = ASAccessorySession()
    let homeManager = HMHomeManager()
    
    func setupMatterDevice() {
        // Matter 프로토콜 지원 액세서리
        let matterItem = ASPickerDisplayItem(
            name: "Matter Smart Light",
            productImage: UIImage(systemName: "lightbulb.fill")!,
            descriptor: ASDiscoveryDescriptor(
                bluetoothServiceUUID: CBUUID(string: "FFF6")  // Matter BLE Service
            )
        )
        
        session.showPicker(for: [matterItem]) { [weak self] error in
            if error == nil {
                // HomeKit에 추가
                self?.addToHomeKit()
            }
        }
    }
    
    private func addToHomeKit() {
        // HomeKit 통합 로직
    }
}
```

### 4. 액세서리 펌웨어 업데이트

```swift
func checkForFirmwareUpdate(accessory: ASAccessory) async {
    // CoreBluetooth를 통해 펌웨어 버전 확인
    guard let identifier = accessory.bluetoothIdentifier else { return }
    
    // 펌웨어 업데이트 가능 여부 확인
    let currentVersion = await fetchFirmwareVersion(identifier)
    let latestVersion = await fetchLatestVersion()
    
    if latestVersion > currentVersion {
        // 업데이트 UI 표시
        await showFirmwareUpdateUI(accessory: accessory, version: latestVersion)
    }
}
```

## 주의사항

1. **iOS 버전**
   - AccessorySetupKit: iOS 18+ 필요
   - 이전 버전은 CoreBluetooth 사용

2. **개인정보 문자열**
   - Bluetooth, 로컬 네트워크 권한 설명 필수
   - 누락 시 앱 거부

3. **시스템 UI**
   - 피커는 시스템 제공 UI 사용
   - 커스터마이징 제한적

4. **백그라운드 제한**
   - 피커는 포그라운드에서만 동작
   - 연결된 액세서리와의 통신은 백그라운드 가능

5. **시뮬레이터**
   - Bluetooth 기능 미지원
   - 실기기 테스트 필수
