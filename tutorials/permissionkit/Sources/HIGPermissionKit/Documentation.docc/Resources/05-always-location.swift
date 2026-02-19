#if canImport(PermissionKit)
import PermissionKit
import CoreLocation
import SwiftUI

// 'Always' 위치 권한 - 단계적 요청
@Observable
final class AlwaysLocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var isRequestingUpgrade = false
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        authorizationStatus = locationManager.authorizationStatus
    }
    
    /// 1단계: 먼저 'When In Use' 권한 요청
    func requestWhenInUseFirst() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// 2단계: 'Always' 권한으로 업그레이드 요청
    /// When In Use를 획득한 후에만 호출해야 합니다
    func requestAlwaysAuthorization() {
        guard authorizationStatus == .authorizedWhenInUse else {
            print("먼저 'When In Use' 권한을 획득해야 합니다")
            return
        }
        
        isRequestingUpgrade = true
        locationManager.requestAlwaysAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        isRequestingUpgrade = false
    }
}

// Always 권한 요청 플로우 뷰
struct AlwaysLocationPermissionView: View {
    @State private var manager = AlwaysLocationManager()
    @State private var currentStep = 0
    
    var body: some View {
        VStack(spacing: 24) {
            // 진행 단계 표시
            HStack {
                StepIndicator(step: 1, current: currentStep, title: "기본 권한")
                StepIndicator(step: 2, current: currentStep, title: "백그라운드")
            }
            .padding(.horizontal)
            
            Spacer()
            
            // 현재 단계별 콘텐츠
            if manager.authorizationStatus == .authorizedAlways {
                completedView
            } else if manager.authorizationStatus == .authorizedWhenInUse {
                upgradePromptView
            } else {
                initialPromptView
            }
            
            Spacer()
        }
        .padding()
        .onChange(of: manager.authorizationStatus) { _, newStatus in
            updateStep(for: newStatus)
        }
    }
    
    private var initialPromptView: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.run")
                .font(.system(size: 60))
                .foregroundStyle(.orange.gradient)
            
            Text("운동 기록 시작하기")
                .font(.title2.bold())
            
            Text("달리기, 자전거 등 운동 경로를 기록하려면\n위치 권한이 필요합니다.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            Button("위치 권한 허용") {
                manager.requestWhenInUseFirst()
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private var upgradePromptView: some View {
        VStack(spacing: 16) {
            Image(systemName: "location.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue.gradient)
            
            Text("백그라운드 위치 활성화")
                .font(.title2.bold())
            
            Text("화면이 꺼져도 운동 경로를 정확하게 기록하려면\n'항상 허용'이 필요합니다.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 12) {
                Button("항상 허용하기") {
                    manager.requestAlwaysAuthorization()
                }
                .buttonStyle(.borderedProminent)
                
                Button("나중에") {
                    // 사용자가 거부해도 기본 기능은 사용 가능
                }
                .foregroundStyle(.secondary)
            }
        }
    }
    
    private var completedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)
            
            Text("설정 완료!")
                .font(.title2.bold())
            
            Text("백그라운드에서도 운동 경로가 기록됩니다.")
                .foregroundStyle(.secondary)
        }
    }
    
    private func updateStep(for status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined: currentStep = 0
        case .authorizedWhenInUse: currentStep = 1
        case .authorizedAlways: currentStep = 2
        default: break
        }
    }
}

struct StepIndicator: View {
    let step: Int
    let current: Int
    let title: String
    
    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(step <= current ? Color.blue : Color.gray.opacity(0.3))
                .frame(width: 24, height: 24)
                .overlay {
                    if step < current {
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                    } else {
                        Text("\(step)")
                            .font(.caption.bold())
                            .foregroundStyle(step <= current ? .white : .gray)
                    }
                }
            
            Text(title)
                .font(.caption)
                .foregroundStyle(step <= current ? .primary : .secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// iOS 26 PermissionKit - HIG Lab
#endif
