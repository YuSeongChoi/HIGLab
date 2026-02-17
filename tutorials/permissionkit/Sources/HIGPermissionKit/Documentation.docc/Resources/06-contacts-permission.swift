import PermissionKit
import Contacts
import SwiftUI

// iOS 18+ Limited Access 지원 연락처 권한 관리
@Observable
final class ContactsPermissionManager {
    private let store = CNContactStore()
    
    var authorizationStatus: CNAuthorizationStatus = .notDetermined
    
    var isLimitedAccess: Bool {
        if #available(iOS 18.0, *) {
            return authorizationStatus == .limited
        }
        return false
    }
    
    var isFullAccess: Bool {
        authorizationStatus == .authorized
    }
    
    init() {
        refreshStatus()
    }
    
    func refreshStatus() {
        authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
    }
    
    /// 연락처 권한 요청
    func requestAccess() async -> Bool {
        do {
            let granted = try await store.requestAccess(for: .contacts)
            await MainActor.run {
                refreshStatus()
            }
            return granted
        } catch {
            print("연락처 권한 요청 실패: \(error)")
            return false
        }
    }
    
    /// iOS 18+: 추가 연락처 선택 요청
    /// Limited Access 상태에서 더 많은 연락처를 공유하도록 요청
    @available(iOS 18.0, *)
    func requestMoreContacts() async {
        // ContactAccessButton 또는 ContactAccessPicker 사용 권장
        // 시스템 UI를 통해 사용자가 추가 연락처를 선택할 수 있음
    }
}

// 연락처 권한 상태 뷰
struct ContactsPermissionView: View {
    @State private var manager = ContactsPermissionManager()
    
    var body: some View {
        VStack(spacing: 20) {
            statusIcon
            
            Text(statusTitle)
                .font(.title2.bold())
            
            Text(statusDescription)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            actionButton
        }
        .padding()
    }
    
    @ViewBuilder
    private var statusIcon: some View {
        switch manager.authorizationStatus {
        case .notDetermined:
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
        case .authorized:
            Image(systemName: "person.crop.circle.badge.checkmark")
                .font(.system(size: 60))
                .foregroundStyle(.green)
        case .limited:
            Image(systemName: "person.crop.circle.badge.minus")
                .font(.system(size: 60))
                .foregroundStyle(.orange)
        case .denied:
            Image(systemName: "person.crop.circle.badge.xmark")
                .font(.system(size: 60))
                .foregroundStyle(.red)
        @unknown default:
            Image(systemName: "person.crop.circle")
                .font(.system(size: 60))
        }
    }
    
    private var statusTitle: String {
        switch manager.authorizationStatus {
        case .notDetermined: return "연락처 접근 필요"
        case .authorized: return "전체 연락처 접근 가능"
        case .limited: return "일부 연락처만 접근 가능"
        case .denied: return "연락처 접근 거부됨"
        @unknown default: return "알 수 없음"
        }
    }
    
    private var statusDescription: String {
        switch manager.authorizationStatus {
        case .notDetermined:
            return "친구를 초대하려면 연락처 권한이 필요합니다."
        case .authorized:
            return "모든 연락처에 접근할 수 있습니다."
        case .limited:
            return "선택한 연락처에만 접근할 수 있습니다.\n더 많은 연락처를 추가할 수 있습니다."
        case .denied:
            return "설정에서 연락처 권한을 허용해주세요."
        @unknown default:
            return ""
        }
    }
    
    @ViewBuilder
    private var actionButton: some View {
        switch manager.authorizationStatus {
        case .notDetermined:
            Button("연락처 권한 허용") {
                Task {
                    await manager.requestAccess()
                }
            }
            .buttonStyle(.borderedProminent)
            
        case .limited:
            Button("연락처 더 추가하기") {
                // iOS 18+ ContactAccessPicker 표시
            }
            .buttonStyle(.bordered)
            
        case .denied:
            Button("설정으로 이동") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.bordered)
            
        default:
            EmptyView()
        }
    }
}

// iOS 26 PermissionKit - HIG Lab
