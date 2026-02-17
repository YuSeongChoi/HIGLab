import PermissionKit
import EventKit
import SwiftUI

// 리마인더 권한 관리
@Observable
final class RemindersPermissionManager {
    private let eventStore = EKEventStore()
    
    var authorizationStatus: EKAuthorizationStatus = .notDetermined
    
    init() {
        refreshStatus()
    }
    
    func refreshStatus() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .reminder)
    }
    
    /// iOS 17+: 전체 리마인더 접근 권한 요청
    @available(iOS 17.0, *)
    func requestFullAccess() async -> Bool {
        do {
            let granted = try await eventStore.requestFullAccessToReminders()
            await MainActor.run {
                refreshStatus()
            }
            return granted
        } catch {
            print("리마인더 권한 요청 실패: \(error)")
            return false
        }
    }
    
    /// 리마인더 가져오기
    func fetchReminders() async -> [EKReminder] {
        let predicate = eventStore.predicateForReminders(in: nil)
        
        return await withCheckedContinuation { continuation in
            eventStore.fetchReminders(matching: predicate) { reminders in
                continuation.resume(returning: reminders ?? [])
            }
        }
    }
}

// 리마인더 권한 및 목록 뷰
struct RemindersView: View {
    @State private var manager = RemindersPermissionManager()
    @State private var reminders: [EKReminder] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            Group {
                switch manager.authorizationStatus {
                case .fullAccess, .authorized:
                    remindersList
                    
                case .notDetermined:
                    permissionPrompt
                    
                default:
                    deniedView
                }
            }
            .navigationTitle("리마인더")
        }
    }
    
    private var permissionPrompt: some View {
        VStack(spacing: 20) {
            Image(systemName: "checklist")
                .font(.system(size: 60))
                .foregroundStyle(.blue.gradient)
            
            Text("리마인더 접근 필요")
                .font(.title2.bold())
            
            Text("할 일 목록을 관리하려면\n리마인더 권한이 필요합니다.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            Button("리마인더 권한 허용") {
                Task {
                    if #available(iOS 17.0, *) {
                        await manager.requestFullAccess()
                    }
                    await loadReminders()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private var remindersList: some View {
        Group {
            if reminders.isEmpty {
                ContentUnavailableView {
                    Label("리마인더 없음", systemImage: "checklist")
                } description: {
                    Text("등록된 리마인더가 없습니다.")
                }
            } else {
                List(reminders, id: \.calendarItemIdentifier) { reminder in
                    HStack {
                        Image(systemName: reminder.isCompleted
                              ? "checkmark.circle.fill"
                              : "circle")
                        .foregroundStyle(reminder.isCompleted ? .green : .secondary)
                        
                        Text(reminder.title)
                            .strikethrough(reminder.isCompleted)
                    }
                }
            }
        }
        .task {
            await loadReminders()
        }
    }
    
    private var deniedView: some View {
        ContentUnavailableView {
            Label("권한 필요", systemImage: "lock.fill")
        } description: {
            Text("설정에서 리마인더 권한을 허용해주세요.")
        } actions: {
            Button("설정으로 이동") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    private func loadReminders() async {
        isLoading = true
        reminders = await manager.fetchReminders()
        isLoading = false
    }
}

// iOS 26 PermissionKit - HIG Lab
