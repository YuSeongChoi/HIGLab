// ContentView.swift
// PermissionHub - iOS 26 PermissionKit 샘플
// 메인 컨텐츠 뷰 - 권한 상태 대시보드

import SwiftUI
import PermissionKit

// MARK: - 메인 컨텐츠 뷰
struct ContentView: View {
    /// 권한 관리자
    @Environment(PermissionManager.self) private var permissionManager
    
    /// 선택된 탭
    @State private var selectedTab: Tab = .dashboard
    
    /// 상세 보기 중인 권한
    @State private var selectedPermission: PermissionInfo?
    
    /// 설정 시트 표시 여부
    @State private var showingSettings = false
    
    /// 변경 이력 시트 표시 여부
    @State private var showingHistory = false
    
    // MARK: - 탭 정의
    enum Tab: String, CaseIterable {
        case dashboard = "대시보드"
        case permissions = "권한 목록"
        case groups = "그룹별 보기"
        
        var iconName: String {
            switch self {
            case .dashboard: return "square.grid.2x2.fill"
            case .permissions: return "list.bullet"
            case .groups: return "folder.fill"
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 대시보드 탭
            DashboardView()
                .tabItem {
                    Label(Tab.dashboard.rawValue, systemImage: Tab.dashboard.iconName)
                }
                .tag(Tab.dashboard)
            
            // 권한 목록 탭
            PermissionListView(selectedPermission: $selectedPermission)
                .tabItem {
                    Label(Tab.permissions.rawValue, systemImage: Tab.permissions.iconName)
                }
                .tag(Tab.permissions)
            
            // 그룹별 보기 탭
            GroupedPermissionView(selectedPermission: $selectedPermission)
                .tabItem {
                    Label(Tab.groups.rawValue, systemImage: Tab.groups.iconName)
                }
                .tag(Tab.groups)
        }
        .tint(.blue)
        .sheet(item: $selectedPermission) { permission in
            PermissionDetailSheet(permission: permission)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingHistory) {
            ChangeHistoryView()
        }
    }
}

// MARK: - 대시보드 뷰
struct DashboardView: View {
    @Environment(PermissionManager.self) private var permissionManager
    
    /// 새로고침 중 여부
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 전체 통계 카드
                    overallStatsCard
                    
                    // 상태별 요약
                    statusSummarySection
                    
                    // 필수 권한 상태
                    essentialPermissionsSection
                    
                    // 빠른 작업 버튼
                    quickActionsSection
                }
                .padding()
            }
            .navigationTitle("권한 허브")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        refreshPermissions()
                    } label: {
                        if isRefreshing {
                            ProgressView()
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    .disabled(isRefreshing)
                }
            }
            .refreshable {
                await permissionManager.refreshAllPermissionStatuses()
            }
        }
    }
    
    // MARK: - 전체 통계 카드
    private var overallStatsCard: some View {
        VStack(spacing: 16) {
            // 진행률 링
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                
                Circle()
                    .trim(from: 0, to: permissionManager.overallGrantedRatio)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .green],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring, value: permissionManager.overallGrantedRatio)
                
                VStack(spacing: 4) {
                    Text("\(Int(permissionManager.overallGrantedRatio * 100))%")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                    Text("허용됨")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 140, height: 140)
            
            // 통계 숫자
            HStack(spacing: 32) {
                StatItem(
                    value: permissionManager.grantedPermissions.count,
                    label: "허용",
                    color: .green
                )
                StatItem(
                    value: permissionManager.deniedPermissions.count,
                    label: "거부",
                    color: .red
                )
                StatItem(
                    value: permissionManager.pendingPermissions.count,
                    label: "대기",
                    color: .orange
                )
            }
        }
        .padding(24)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
        }
    }
    
    // MARK: - 상태별 요약
    private var statusSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("상태별 요약")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(summaryItems, id: \.status) { item in
                    StatusSummaryCard(
                        status: item.status,
                        count: item.count,
                        iconName: item.status.iconName,
                        color: statusColor(item.status)
                    )
                }
            }
        }
    }
    
    private var summaryItems: [(status: PermissionStatus, count: Int)] {
        let grouped = Dictionary(grouping: permissionManager.permissions.values) { $0.status }
        return [
            (.authorized, grouped[.authorized]?.count ?? 0),
            (.denied, grouped[.denied]?.count ?? 0),
            (.limited, grouped[.limited]?.count ?? 0),
            (.notDetermined, grouped[.notDetermined]?.count ?? 0)
        ]
    }
    
    private func statusColor(_ status: PermissionStatus) -> Color {
        switch status {
        case .authorized: return .green
        case .denied: return .red
        case .limited: return .yellow
        case .notDetermined: return .gray
        default: return .secondary
        }
    }
    
    // MARK: - 필수 권한 상태
    private var essentialPermissionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("필수 권한")
                    .font(.headline)
                
                Spacer()
                
                if !allEssentialGranted {
                    Button("모두 요청") {
                        requestAllEssential()
                    }
                    .font(.caption)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                }
            }
            
            VStack(spacing: 8) {
                ForEach(essentialPermissions) { permission in
                    EssentialPermissionRow(permission: permission)
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.regularMaterial)
            }
        }
    }
    
    private var essentialPermissions: [PermissionInfo] {
        PermissionType.allCases
            .filter { $0.isEssential }
            .compactMap { permissionManager.permissions[$0] }
    }
    
    private var allEssentialGranted: Bool {
        essentialPermissions.allSatisfy { $0.status.isGranted }
    }
    
    // MARK: - 빠른 작업
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("빠른 작업")
                .font(.headline)
            
            HStack(spacing: 12) {
                QuickActionButton(
                    title: "설정 열기",
                    iconName: "gear",
                    color: .blue
                ) {
                    SettingsHelper.openAppSettings()
                }
                
                QuickActionButton(
                    title: "모두 새로고침",
                    iconName: "arrow.clockwise",
                    color: .green
                ) {
                    refreshPermissions()
                }
            }
        }
    }
    
    // MARK: - 액션
    private func refreshPermissions() {
        isRefreshing = true
        Task {
            await permissionManager.refreshAllPermissionStatuses()
            isRefreshing = false
        }
    }
    
    private func requestAllEssential() {
        Task {
            _ = await permissionManager.requestEssentialPermissions()
        }
    }
}

// MARK: - 통계 아이템
struct StatItem: View {
    let value: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title2.bold())
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - 상태 요약 카드
struct StatusSummaryCard: View {
    let status: PermissionStatus
    let count: Int
    let iconName: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundStyle(color)
            
            VStack(alignment: .leading) {
                Text("\(count)")
                    .font(.title3.bold())
                Text(status.displayText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        }
    }
}

// MARK: - 필수 권한 행
struct EssentialPermissionRow: View {
    let permission: PermissionInfo
    @Environment(PermissionManager.self) private var permissionManager
    
    var body: some View {
        HStack {
            Image(systemName: permission.iconName)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading) {
                Text(permission.displayName)
                    .font(.subheadline.weight(.medium))
                Text(permission.status.displayText)
                    .font(.caption)
                    .foregroundStyle(statusColor)
            }
            
            Spacer()
            
            if permission.status.canRequest {
                Button("요청") {
                    Task {
                        _ = await permissionManager.requestPermission(for: permission.type)
                    }
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .controlSize(.small)
            } else {
                Image(systemName: permission.status.iconName)
                    .foregroundStyle(statusColor)
            }
        }
    }
    
    private var statusColor: Color {
        switch permission.status {
        case .authorized: return .green
        case .denied: return .red
        case .notDetermined: return .orange
        default: return .secondary
        }
    }
}

// MARK: - 빠른 작업 버튼
struct QuickActionButton: View {
    let title: String
    let iconName: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
            }
            .foregroundStyle(color)
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environment(PermissionManager())
}
