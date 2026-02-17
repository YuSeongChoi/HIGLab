import SwiftUI
import EventKit

// MARK: - 메인 컨텐츠 뷰
/// 탭 기반 네비게이션과 권한 요청을 처리하는 메인 뷰
struct ContentView: View {
    @EnvironmentObject var eventKitManager: EventKitManager
    @State private var selectedTab: AppTab = .calendar
    @State private var showingPermissionAlert = false
    
    var body: some View {
        Group {
            // 권한 상태에 따른 뷰 분기
            if needsPermission {
                PermissionRequestView()
            } else {
                mainTabView
            }
        }
        .task {
            // 앱 시작 시 데이터 로드
            await eventKitManager.refreshAllData()
        }
    }
    
    // MARK: - 권한 필요 여부
    private var needsPermission: Bool {
        let calendarStatus = eventKitManager.calendarAuthorizationStatus
        let reminderStatus = eventKitManager.reminderAuthorizationStatus
        
        // 둘 다 권한이 없으면 권한 요청 화면 표시
        let calendarNotGranted = calendarStatus != .fullAccess && calendarStatus != .authorized
        let reminderNotGranted = reminderStatus != .fullAccess && reminderStatus != .authorized
        
        return calendarNotGranted && reminderNotGranted
    }
    
    // MARK: - 메인 탭 뷰
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            CalendarView()
                .tabItem {
                    Label(AppTab.calendar.rawValue, systemImage: AppTab.calendar.symbolName)
                }
                .tag(AppTab.calendar)
            
            ReminderListView()
                .tabItem {
                    Label(AppTab.reminders.rawValue, systemImage: AppTab.reminders.symbolName)
                }
                .tag(AppTab.reminders)
        }
    }
}

// MARK: - 권한 요청 뷰
/// 캘린더와 리마인더 권한을 요청하는 온보딩 뷰
struct PermissionRequestView: View {
    @EnvironmentObject var eventKitManager: EventKitManager
    @State private var isRequestingCalendar = false
    @State private var isRequestingReminder = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                // 앱 아이콘 및 소개
                headerSection
                
                // 권한 요청 버튼들
                permissionButtons
                
                Spacer()
                
                // 설명 문구
                footerSection
            }
            .padding()
            .navigationTitle("CalendarPlus")
        }
    }
    
    // MARK: - 헤더 섹션
    private var headerSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.checkmark")
                .font(.system(size: 80))
                .foregroundStyle(.blue, .green)
                .padding(.top, 40)
            
            Text("일정과 할 일을 한 곳에서")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("캘린더와 미리알림을 효율적으로 관리하세요")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - 권한 요청 버튼들
    private var permissionButtons: some View {
        VStack(spacing: 16) {
            // 캘린더 권한 요청
            PermissionButton(
                title: "캘린더 접근 허용",
                subtitle: "일정을 확인하고 관리합니다",
                symbolName: "calendar",
                status: eventKitManager.calendarAuthorizationStatus,
                isLoading: isRequestingCalendar
            ) {
                await requestCalendarAccess()
            }
            
            // 리마인더 권한 요청
            PermissionButton(
                title: "미리알림 접근 허용",
                subtitle: "할 일을 확인하고 관리합니다",
                symbolName: "checklist",
                status: eventKitManager.reminderAuthorizationStatus,
                isLoading: isRequestingReminder
            ) {
                await requestReminderAccess()
            }
        }
    }
    
    // MARK: - 푸터 섹션
    private var footerSection: some View {
        VStack(spacing: 8) {
            Text("앱이 제대로 동작하려면 최소 하나의 권한이 필요합니다")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            if eventKitManager.calendarAuthorizationStatus == .denied ||
               eventKitManager.reminderAuthorizationStatus == .denied {
                Button("설정에서 권한 변경") {
                    openSettings()
                }
                .font(.caption)
            }
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - 캘린더 권한 요청
    private func requestCalendarAccess() async {
        isRequestingCalendar = true
        defer { isRequestingCalendar = false }
        
        _ = await eventKitManager.requestCalendarAccess()
    }
    
    // MARK: - 리마인더 권한 요청
    private func requestReminderAccess() async {
        isRequestingReminder = true
        defer { isRequestingReminder = false }
        
        _ = await eventKitManager.requestReminderAccess()
    }
    
    // MARK: - 설정 앱 열기
    private func openSettings() {
        #if os(iOS)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
        #elseif os(macOS)
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars") {
            NSWorkspace.shared.open(url)
        }
        #endif
    }
}

// MARK: - 권한 요청 버튼 컴포넌트
struct PermissionButton: View {
    let title: String
    let subtitle: String
    let symbolName: String
    let status: EKAuthorizationStatus
    let isLoading: Bool
    let action: () async -> Void
    
    var body: some View {
        Button {
            Task {
                await action()
            }
        } label: {
            HStack(spacing: 16) {
                // 아이콘
                Image(systemName: symbolName)
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(statusColor.opacity(0.15))
                    .foregroundStyle(statusColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                // 텍스트
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // 상태 표시
                statusIndicator
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isLoading || status == .fullAccess || status == .authorized)
    }
    
    // MARK: - 상태 색상
    private var statusColor: Color {
        switch status {
        case .fullAccess, .authorized:
            return .green
        case .denied:
            return .red
        case .restricted:
            return .orange
        case .notDetermined, .writeOnly:
            return .blue
        @unknown default:
            return .gray
        }
    }
    
    // MARK: - 상태 표시기
    @ViewBuilder
    private var statusIndicator: some View {
        if isLoading {
            ProgressView()
        } else {
            switch status {
            case .fullAccess, .authorized:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            case .denied:
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.red)
            case .restricted:
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
            case .notDetermined, .writeOnly:
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            @unknown default:
                EmptyView()
            }
        }
    }
}

// MARK: - 미리보기
#Preview {
    ContentView()
        .environmentObject(EventKitManager.shared)
}

#Preview("Permission Request") {
    PermissionRequestView()
        .environmentObject(EventKitManager.shared)
}
