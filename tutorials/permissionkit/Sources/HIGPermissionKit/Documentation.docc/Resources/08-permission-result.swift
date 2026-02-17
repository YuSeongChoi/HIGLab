import PermissionKit
import SwiftUI

// 권한 요청 결과 처리
enum PermissionResult {
    case granted           // 허용됨
    case denied            // 거부됨
    case limited           // 제한적 접근 (연락처, 사진 등)
    case restricted        // 시스템에서 제한됨
    case notDetermined     // 아직 결정되지 않음
    
    var isAccessible: Bool {
        switch self {
        case .granted, .limited:
            return true
        default:
            return false
        }
    }
    
    var userMessage: String {
        switch self {
        case .granted:
            return "권한이 허용되었습니다."
        case .denied:
            return "권한이 거부되었습니다. 설정에서 변경할 수 있습니다."
        case .limited:
            return "일부 데이터에만 접근할 수 있습니다."
        case .restricted:
            return "이 기능은 현재 사용할 수 없습니다."
        case .notDetermined:
            return "권한을 요청해주세요."
        }
    }
}

// 권한 결과에 따른 분기 처리 뷰
struct PermissionResultView: View {
    let permissionName: String
    let result: PermissionResult
    let onRetry: (() -> Void)?
    let onOpenSettings: () -> Void
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            resultIcon
            
            Text(resultTitle)
                .font(.title2.bold())
            
            Text(result.userMessage)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            resultActions
        }
        .padding()
    }
    
    @ViewBuilder
    private var resultIcon: some View {
        switch result {
        case .granted:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)
        case .denied:
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.red)
        case .limited:
            Image(systemName: "minus.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.orange)
        case .restricted:
            Image(systemName: "lock.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.gray)
        case .notDetermined:
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
        }
    }
    
    private var resultTitle: String {
        switch result {
        case .granted: return "\(permissionName) 설정 완료"
        case .denied: return "\(permissionName) 거부됨"
        case .limited: return "\(permissionName) 제한적 접근"
        case .restricted: return "\(permissionName) 사용 불가"
        case .notDetermined: return "\(permissionName) 설정 필요"
        }
    }
    
    @ViewBuilder
    private var resultActions: some View {
        switch result {
        case .granted, .limited:
            Button("계속하기", action: onContinue)
                .buttonStyle(.borderedProminent)
            
        case .denied:
            VStack(spacing: 12) {
                Button("설정에서 변경", action: onOpenSettings)
                    .buttonStyle(.borderedProminent)
                
                Button("나중에 설정", action: onContinue)
                    .foregroundStyle(.secondary)
            }
            
        case .restricted:
            Button("계속하기", action: onContinue)
                .buttonStyle(.bordered)
            
        case .notDetermined:
            if let retry = onRetry {
                Button("권한 요청", action: retry)
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}

// 사용 예시
struct PermissionResultExample: View {
    @State private var showResult = false
    @State private var result: PermissionResult = .notDetermined
    
    var body: some View {
        VStack {
            Button("권한 테스트") {
                // 권한 요청 후 결과 설정
                result = .granted
                showResult = true
            }
        }
        .sheet(isPresented: $showResult) {
            PermissionResultView(
                permissionName: "카메라",
                result: result,
                onRetry: { /* 재요청 */ },
                onOpenSettings: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                },
                onContinue: {
                    showResult = false
                }
            )
        }
    }
}

// iOS 26 PermissionKit - HIG Lab
