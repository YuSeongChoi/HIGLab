import SwiftUI
import CoreBluetooth
import CoreLocation

@Observable
class PermissionManager {
    var bluetoothStatus: CBManagerAuthorization = .notDetermined
    var locationStatus: CLAuthorizationStatus = .notDetermined
    
    var allPermissionsGranted: Bool {
        bluetoothStatus == .allowedAlways &&
        (locationStatus == .authorizedWhenInUse || locationStatus == .authorizedAlways)
    }
    
    // 권한 상태 확인
    func checkPermissions() {
        bluetoothStatus = CBCentralManager.authorization
        locationStatus = CLLocationManager().authorizationStatus
    }
}

struct PermissionFlowView: View {
    @State private var permissionManager = PermissionManager()
    @State private var currentStep = 0
    
    var body: some View {
        VStack(spacing: 32) {
            // 진행 인디케이터
            ProgressIndicator(current: currentStep, total: 2)
            
            // 단계별 권한 요청
            TabView(selection: $currentStep) {
                BluetoothPermissionStep(
                    status: permissionManager.bluetoothStatus,
                    onComplete: { currentStep = 1 }
                )
                .tag(0)
                
                LocationPermissionStep(
                    status: permissionManager.locationStatus,
                    onComplete: { currentStep = 2 }
                )
                .tag(1)
                
                SetupCompleteStep()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .onAppear {
            permissionManager.checkPermissions()
        }
    }
}

struct BluetoothPermissionStep: View {
    let status: CBManagerAuthorization
    let onComplete: () -> Void
    
    var body: some View {
        PermissionStepView(
            icon: "bluetooth",
            title: "Bluetooth 권한",
            description: "기기와 연결하려면 Bluetooth 권한이 필요합니다.",
            isGranted: status == .allowedAlways,
            requestAction: {
                // Bluetooth 권한은 CBCentralManager 생성 시 자동 요청
                _ = CBCentralManager()
            },
            onComplete: onComplete
        )
    }
}

struct LocationPermissionStep: View {
    let status: CLAuthorizationStatus
    let onComplete: () -> Void
    
    private let locationManager = CLLocationManager()
    
    var body: some View {
        PermissionStepView(
            icon: "location",
            title: "위치 권한",
            description: "Wi-Fi 기기 검색을 위해 위치 권한이 필요합니다.",
            isGranted: status == .authorizedWhenInUse || status == .authorizedAlways,
            requestAction: {
                locationManager.requestWhenInUseAuthorization()
            },
            onComplete: onComplete
        )
    }
}

struct PermissionStepView: View {
    let icon: String
    let title: String
    let description: String
    let isGranted: Bool
    let requestAction: () -> Void
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(isGranted ? .green : .blue)
            
            Text(title)
                .font(.title.bold())
            
            Text(description)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            if isGranted {
                Label("허용됨", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                
                Button("계속") {
                    onComplete()
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("권한 허용") {
                    requestAction()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}

struct ProgressIndicator: View {
    let current: Int
    let total: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(index <= current ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

struct SetupCompleteStep: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)
            
            Text("설정 완료!")
                .font(.title.bold())
            
            Text("이제 기기를 추가할 준비가 되었습니다.")
                .foregroundStyle(.secondary)
        }
    }
}
