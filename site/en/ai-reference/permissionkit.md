# PermissionKit AI Reference

> 시스템 권한 관리 가이드. 이 문서를 읽고 PermissionKit 코드를 생성할 수 있습니다.

## 개요

PermissionKit은 iOS 18+에서 제공하는 통합 권한 관리 프레임워크입니다.
카메라, 마이크, 위치, 사진 등 다양한 시스템 권한을 일관된 API로 요청하고 관리할 수 있습니다.

## 필수 Import

```swift
import PermissionKit
```

## 프로젝트 설정

### Info.plist (필요한 권한별)

```xml
<!-- 카메라 -->
<key>NSCameraUsageDescription</key>
<string>사진 촬영을 위해 카메라 접근이 필요합니다.</string>

<!-- 마이크 -->
<key>NSMicrophoneUsageDescription</key>
<string>음성 녹음을 위해 마이크 접근이 필요합니다.</string>

<!-- 위치 -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>현재 위치를 확인하기 위해 필요합니다.</string>

<!-- 사진 라이브러리 -->
<key>NSPhotoLibraryUsageDescription</key>
<string>사진을 저장하고 불러오기 위해 필요합니다.</string>

<!-- 연락처 -->
<key>NSContactsUsageDescription</key>
<string>연락처를 불러오기 위해 필요합니다.</string>

<!-- 알림 -->
<key>NSUserNotificationsUsageDescription</key>
<string>알림을 보내기 위해 필요합니다.</string>

<!-- 건강 -->
<key>NSHealthShareUsageDescription</key>
<string>건강 데이터를 읽기 위해 필요합니다.</string>
```

## 핵심 구성요소

### 1. PermissionManager

```swift
import PermissionKit

// 권한 매니저
let permissionManager = PermissionManager.shared

// 단일 권한 요청
let status = await permissionManager.request(.camera)

// 여러 권한 동시 요청
let results = await permissionManager.request([.camera, .microphone, .photoLibrary])
```

### 2. PermissionType (권한 유형)

```swift
// 지원하는 권한 유형
PermissionType.camera           // 카메라
PermissionType.microphone       // 마이크
PermissionType.photoLibrary     // 사진 라이브러리
PermissionType.location         // 위치 (사용 중)
PermissionType.locationAlways   // 위치 (항상)
PermissionType.contacts         // 연락처
PermissionType.calendar         // 캘린더
PermissionType.reminders        // 미리알림
PermissionType.notifications    // 알림
PermissionType.bluetooth        // 블루투스
PermissionType.motion           // 모션
PermissionType.health           // 건강
```

### 3. PermissionStatus (권한 상태)

```swift
// 권한 상태 확인
let status = await permissionManager.status(for: .camera)

switch status {
case .notDetermined:
    // 아직 요청 안 함
case .authorized:
    // 허용됨
case .denied:
    // 거부됨
case .restricted:
    // 제한됨 (보호자 설정 등)
case .limited:
    // 제한적 접근 (사진 일부만 등)
}
```

## 전체 작동 예제

```swift
import SwiftUI
import PermissionKit

// MARK: - Permission View Model
@Observable
class PermissionViewModel {
    var permissions: [PermissionItem] = []
    var showingSettingsAlert = false
    
    private let permissionManager = PermissionManager.shared
    
    init() {
        setupPermissions()
    }
    
    func setupPermissions() {
        permissions = [
            PermissionItem(type: .camera, title: "카메라", icon: "camera.fill", description: "사진 및 동영상 촬영"),
            PermissionItem(type: .microphone, title: "마이크", icon: "mic.fill", description: "음성 녹음"),
            PermissionItem(type: .photoLibrary, title: "사진", icon: "photo.fill", description: "사진 저장 및 불러오기"),
            PermissionItem(type: .location, title: "위치", icon: "location.fill", description: "현재 위치 확인"),
            PermissionItem(type: .contacts, title: "연락처", icon: "person.crop.circle.fill", description: "연락처 접근"),
            PermissionItem(type: .notifications, title: "알림", icon: "bell.fill", description: "푸시 알림 수신"),
            PermissionItem(type: .calendar, title: "캘린더", icon: "calendar", description: "일정 접근"),
            PermissionItem(type: .motion, title: "모션", icon: "figure.walk", description: "걸음 수 및 활동")
        ]
        
        Task {
            await refreshStatuses()
        }
    }
    
    func refreshStatuses() async {
        for index in permissions.indices {
            let status = await permissionManager.status(for: permissions[index].type)
            await MainActor.run {
                permissions[index].status = status
            }
        }
    }
    
    func requestPermission(_ permission: PermissionItem) async {
        let result = await permissionManager.request(permission.type)
        
        await MainActor.run {
            if let index = permissions.firstIndex(where: { $0.type == permission.type }) {
                permissions[index].status = result
            }
            
            if result == .denied {
                showingSettingsAlert = true
            }
        }
    }
    
    func requestAllPermissions() async {
        let types = permissions.map(\.type)
        let results = await permissionManager.request(types)
        
        await MainActor.run {
            for (type, status) in results {
                if let index = permissions.firstIndex(where: { $0.type == type }) {
                    permissions[index].status = status
                }
            }
        }
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Permission Item
struct PermissionItem: Identifiable {
    let id = UUID()
    let type: PermissionType
    let title: String
    let icon: String
    let description: String
    var status: PermissionStatus = .notDetermined
    
    var statusText: String {
        switch status {
        case .notDetermined: return "요청 필요"
        case .authorized: return "허용됨"
        case .denied: return "거부됨"
        case .restricted: return "제한됨"
        case .limited: return "제한적"
        }
    }
    
    var statusColor: Color {
        switch status {
        case .authorized, .limited: return .green
        case .denied, .restricted: return .red
        case .notDetermined: return .orange
        }
    }
}

// MARK: - Main View
struct PermissionManagerView: View {
    @State private var viewModel = PermissionViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                // 전체 요청 버튼
                Section {
                    Button {
                        Task {
                            await viewModel.requestAllPermissions()
                        }
                    } label: {
                        Label("모든 권한 요청", systemImage: "checkmark.shield.fill")
                    }
                }
                
                // 권한 목록
                Section("권한 목록") {
                    ForEach(viewModel.permissions) { permission in
                        PermissionRow(
                            permission: permission,
                            onRequest: {
                                Task {
                                    await viewModel.requestPermission(permission)
                                }
                            }
                        )
                    }
                }
                
                // 안내
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("권한이 거부된 경우")
                            .font(.subheadline.bold())
                        Text("설정 앱에서 직접 권한을 변경할 수 있습니다.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Button("설정 열기") {
                            viewModel.openSettings()
                        }
                        .font(.subheadline)
                    }
                }
            }
            .navigationTitle("권한 관리")
            .refreshable {
                await viewModel.refreshStatuses()
            }
            .alert("권한 거부됨", isPresented: $viewModel.showingSettingsAlert) {
                Button("설정으로 이동") {
                    viewModel.openSettings()
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("권한이 거부되었습니다. 설정에서 직접 변경해주세요.")
            }
        }
    }
}

// MARK: - Permission Row
struct PermissionRow: View {
    let permission: PermissionItem
    let onRequest: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: permission.icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(permission.title)
                    .font(.headline)
                Text(permission.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(permission.statusText)
                    .font(.caption)
                    .foregroundStyle(permission.statusColor)
                
                if permission.status == .notDetermined {
                    Button("요청") {
                        onRequest()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                } else if permission.status == .denied {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.red)
                } else if permission.status == .authorized {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    PermissionManagerView()
}
```

## 고급 패턴

### 1. 온보딩 권한 요청 플로우

```swift
struct OnboardingPermissionView: View {
    @State private var currentStep = 0
    @State private var isCompleted = false
    @Environment(\.dismiss) private var dismiss
    
    let requiredPermissions: [PermissionType] = [
        .camera,
        .microphone,
        .notifications
    ]
    
    var body: some View {
        VStack(spacing: 32) {
            // 프로그레스
            ProgressView(value: Double(currentStep), total: Double(requiredPermissions.count))
                .padding(.horizontal)
            
            Spacer()
            
            // 현재 권한 설명
            if currentStep < requiredPermissions.count {
                PermissionExplainView(type: requiredPermissions[currentStep])
            } else {
                // 완료
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.green)
                    Text("설정 완료!")
                        .font(.title.bold())
                }
            }
            
            Spacer()
            
            // 버튼
            if currentStep < requiredPermissions.count {
                Button {
                    Task {
                        await requestCurrentPermission()
                    }
                } label: {
                    Text("계속")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button("건너뛰기") {
                    nextStep()
                }
                .foregroundStyle(.secondary)
            } else {
                Button {
                    dismiss()
                } label: {
                    Text("시작하기")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .padding()
    }
    
    func requestCurrentPermission() async {
        let type = requiredPermissions[currentStep]
        _ = await PermissionManager.shared.request(type)
        await MainActor.run {
            nextStep()
        }
    }
    
    func nextStep() {
        withAnimation {
            currentStep += 1
        }
    }
}

struct PermissionExplainView: View {
    let type: PermissionType
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: iconFor(type))
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            Text(titleFor(type))
                .font(.title2.bold())
            
            Text(descriptionFor(type))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
    }
    
    func iconFor(_ type: PermissionType) -> String {
        switch type {
        case .camera: return "camera.fill"
        case .microphone: return "mic.fill"
        case .notifications: return "bell.fill"
        default: return "questionmark.circle"
        }
    }
    
    func titleFor(_ type: PermissionType) -> String {
        switch type {
        case .camera: return "카메라 접근"
        case .microphone: return "마이크 접근"
        case .notifications: return "알림 허용"
        default: return "권한 요청"
        }
    }
    
    func descriptionFor(_ type: PermissionType) -> String {
        switch type {
        case .camera: return "사진과 동영상을 촬영하려면 카메라 접근 권한이 필요합니다."
        case .microphone: return "음성을 녹음하려면 마이크 접근 권한이 필요합니다."
        case .notifications: return "중요한 알림을 받으려면 알림 권한이 필요합니다."
        default: return "이 기능을 사용하려면 권한이 필요합니다."
        }
    }
}
```

### 2. 권한 상태 모니터링

```swift
class PermissionMonitor: ObservableObject {
    @Published var cameraStatus: PermissionStatus = .notDetermined
    @Published var locationStatus: PermissionStatus = .notDetermined
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 권한 상태 변경 구독
        PermissionManager.shared.statusPublisher(for: .camera)
            .receive(on: DispatchQueue.main)
            .assign(to: &$cameraStatus)
        
        PermissionManager.shared.statusPublisher(for: .location)
            .receive(on: DispatchQueue.main)
            .assign(to: &$locationStatus)
        
        // 앱 포그라운드 전환 시 새로고침
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                Task {
                    await self?.refreshStatuses()
                }
            }
            .store(in: &cancellables)
    }
    
    func refreshStatuses() async {
        let camera = await PermissionManager.shared.status(for: .camera)
        let location = await PermissionManager.shared.status(for: .location)
        
        await MainActor.run {
            self.cameraStatus = camera
            self.locationStatus = location
        }
    }
}
```

### 3. 조건부 기능 제공

```swift
struct FeatureView: View {
    @State private var cameraPermission: PermissionStatus = .notDetermined
    
    var body: some View {
        Group {
            switch cameraPermission {
            case .authorized:
                CameraView()
            case .denied, .restricted:
                PermissionDeniedView(
                    permission: .camera,
                    onOpenSettings: openSettings
                )
            case .notDetermined:
                PermissionRequestView(
                    permission: .camera,
                    onRequest: requestPermission
                )
            case .limited:
                LimitedAccessView()
            }
        }
        .task {
            cameraPermission = await PermissionManager.shared.status(for: .camera)
        }
    }
    
    func requestPermission() {
        Task {
            cameraPermission = await PermissionManager.shared.request(.camera)
        }
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
```

## 주의사항

1. **iOS 버전**
   - PermissionKit: iOS 18+ 전용
   - 이전 버전은 개별 프레임워크 API 사용

2. **Info.plist 필수**
   - 각 권한별 Usage Description 필수
   - 누락 시 앱 크래시

3. **권한 거부 처리**
   - 거부된 권한은 앱에서 재요청 불가
   - 설정 앱으로 안내 필요

4. **제한적 접근**
   - 사진 등 일부 권한은 Limited 상태 가능
   - 부분 접근에 맞는 UI 제공 필요

5. **테스트**
   - 시뮬레이터에서 대부분 테스트 가능
   - 일부 권한(Bluetooth 등)은 실기기 필요
