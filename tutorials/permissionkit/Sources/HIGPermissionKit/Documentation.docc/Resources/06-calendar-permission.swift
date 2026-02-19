#if canImport(PermissionKit)
import PermissionKit
import EventKit
import SwiftUI

// 캘린더 권한 관리 (iOS 17+ 대응)
@Observable
final class CalendarPermissionManager {
    private let eventStore = EKEventStore()
    
    var authorizationStatus: EKAuthorizationStatus = .notDetermined
    
    init() {
        refreshStatus()
    }
    
    func refreshStatus() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
    }
    
    /// iOS 17+: 전체 캘린더 접근 권한 요청
    @available(iOS 17.0, *)
    func requestFullAccess() async -> Bool {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            await MainActor.run {
                refreshStatus()
            }
            return granted
        } catch {
            print("캘린더 권한 요청 실패: \(error)")
            return false
        }
    }
    
    /// iOS 17+: 쓰기 전용 접근 권한 요청
    @available(iOS 17.0, *)
    func requestWriteOnlyAccess() async -> Bool {
        do {
            let granted = try await eventStore.requestWriteOnlyAccessToEvents()
            await MainActor.run {
                refreshStatus()
            }
            return granted
        } catch {
            print("캘린더 쓰기 권한 요청 실패: \(error)")
            return false
        }
    }
    
    /// iOS 16 이하: 기존 방식의 권한 요청
    func requestLegacyAccess() async -> Bool {
        await withCheckedContinuation { continuation in
            eventStore.requestAccess(to: .event) { granted, _ in
                Task { @MainActor in
                    self.refreshStatus()
                }
                continuation.resume(returning: granted)
            }
        }
    }
}

// 캘린더 권한 요청 뷰
struct CalendarPermissionView: View {
    @State private var manager = CalendarPermissionManager()
    @State private var selectedAccessType: CalendarAccessType = .full
    
    enum CalendarAccessType {
        case full, writeOnly
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "calendar")
                .font(.system(size: 60))
                .foregroundStyle(.red.gradient)
            
            Text("캘린더 접근")
                .font(.title2.bold())
            
            // 접근 유형 선택 (iOS 17+)
            if #available(iOS 17.0, *) {
                Picker("접근 유형", selection: $selectedAccessType) {
                    Text("전체 접근").tag(CalendarAccessType.full)
                    Text("쓰기만").tag(CalendarAccessType.writeOnly)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
            }
            
            Text(accessTypeDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            statusBadge
            
            if manager.authorizationStatus == .notDetermined {
                Button("캘린더 권한 허용") {
                    Task {
                        await requestAccess()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
    
    private var accessTypeDescription: String {
        switch selectedAccessType {
        case .full:
            return "일정을 확인하고 새로운 일정을 추가할 수 있습니다."
        case .writeOnly:
            return "기존 일정은 볼 수 없고, 새 일정만 추가할 수 있습니다."
        }
    }
    
    @ViewBuilder
    private var statusBadge: some View {
        HStack {
            switch manager.authorizationStatus {
            case .fullAccess:
                Label("전체 접근 허용됨", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            case .writeOnly:
                Label("쓰기만 허용됨", systemImage: "pencil.circle.fill")
                    .foregroundStyle(.blue)
            case .denied:
                Label("접근 거부됨", systemImage: "xmark.circle.fill")
                    .foregroundStyle(.red)
            default:
                EmptyView()
            }
        }
        .font(.subheadline)
    }
    
    private func requestAccess() async {
        if #available(iOS 17.0, *) {
            switch selectedAccessType {
            case .full:
                _ = await manager.requestFullAccess()
            case .writeOnly:
                _ = await manager.requestWriteOnlyAccess()
            }
        } else {
            _ = await manager.requestLegacyAccess()
        }
    }
}

// iOS 26 PermissionKit - HIG Lab
#endif
