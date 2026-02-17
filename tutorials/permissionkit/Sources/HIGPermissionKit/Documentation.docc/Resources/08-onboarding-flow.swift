import PermissionKit
import SwiftUI

// 온보딩 플로우 상태 머신
@Observable
final class OnboardingFlowController {
    var currentState: FlowState = .notStarted
    var permissionResults: [PermissionType: Bool] = [:]
    
    enum FlowState {
        case notStarted
        case inProgress(step: Int)
        case completed
        case skipped
    }
    
    enum PermissionType: String, CaseIterable {
        case notifications
        case camera
        case location
        case contacts
    }
    
    var currentStepIndex: Int {
        switch currentState {
        case .inProgress(let step): return step
        default: return 0
        }
    }
    
    var permissionsToRequest: [PermissionType] {
        // 앱에 필요한 권한들 정의
        [.notifications, .camera, .location]
    }
    
    var progress: Double {
        guard !permissionsToRequest.isEmpty else { return 0 }
        return Double(currentStepIndex) / Double(permissionsToRequest.count)
    }
    
    func start() {
        currentState = .inProgress(step: 0)
    }
    
    func recordResult(_ type: PermissionType, granted: Bool) {
        permissionResults[type] = granted
    }
    
    func advance() {
        switch currentState {
        case .inProgress(let step):
            let nextStep = step + 1
            if nextStep >= permissionsToRequest.count {
                currentState = .completed
            } else {
                currentState = .inProgress(step: nextStep)
            }
        default:
            break
        }
    }
    
    func skip() {
        advance()
    }
    
    func skipAll() {
        currentState = .skipped
    }
    
    var currentPermission: PermissionType? {
        guard case .inProgress(let step) = currentState,
              step < permissionsToRequest.count else {
            return nil
        }
        return permissionsToRequest[step]
    }
    
    // 권한 획득 성공률
    var successRate: Double {
        let granted = permissionResults.values.filter { $0 }.count
        return Double(granted) / Double(permissionsToRequest.count)
    }
}

// 플로우 컨트롤러를 사용하는 온보딩 뷰
struct SmartOnboardingView: View {
    @State private var controller = OnboardingFlowController()
    
    var body: some View {
        ZStack {
            switch controller.currentState {
            case .notStarted:
                WelcomeScreen(onStart: {
                    withAnimation {
                        controller.start()
                    }
                })
                
            case .inProgress:
                if let permission = controller.currentPermission {
                    PermissionRequestScreen(
                        permission: permission,
                        progress: controller.progress,
                        onComplete: { granted in
                            controller.recordResult(permission, granted: granted)
                            withAnimation {
                                controller.advance()
                            }
                        },
                        onSkip: {
                            controller.recordResult(permission, granted: false)
                            withAnimation {
                                controller.skip()
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                }
                
            case .completed, .skipped:
                OnboardingCompleteScreen(
                    results: controller.permissionResults,
                    successRate: controller.successRate
                )
            }
        }
    }
}

struct WelcomeScreen: View {
    let onStart: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "sparkles")
                .font(.system(size: 80))
            Text("앱 설정")
                .font(.largeTitle.bold())
            Spacer()
            Button("시작", action: onStart)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct PermissionRequestScreen: View {
    let permission: OnboardingFlowController.PermissionType
    let progress: Double
    let onComplete: (Bool) -> Void
    let onSkip: () -> Void
    
    var body: some View {
        VStack {
            ProgressView(value: progress)
                .padding()
            
            Spacer()
            
            Text(permission.rawValue)
                .font(.title)
            
            Spacer()
            
            VStack(spacing: 12) {
                Button("허용") {
                    // 실제 권한 요청 후 결과 전달
                    onComplete(true)
                }
                .buttonStyle(.borderedProminent)
                
                Button("건너뛰기", action: onSkip)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}

struct OnboardingCompleteScreen: View {
    let results: [OnboardingFlowController.PermissionType: Bool]
    let successRate: Double
    
    var body: some View {
        VStack {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)
            
            Text("설정 완료")
                .font(.title.bold())
            
            Text("\(Int(successRate * 100))% 권한 허용됨")
                .foregroundStyle(.secondary)
        }
    }
}

// iOS 26 PermissionKit - HIG Lab
