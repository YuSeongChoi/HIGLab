// PermissionStatusView.swift
// PermissionHub - iOS 26 PermissionKit 샘플
// 권한 목록 및 상세 상태 뷰

import SwiftUI
import PermissionKit

// MARK: - 권한 목록 뷰
struct PermissionListView: View {
    @Environment(PermissionManager.self) private var permissionManager
    
    /// 선택된 권한 (상세 보기)
    @Binding var selectedPermission: PermissionInfo?
    
    /// 검색 텍스트
    @State private var searchText = ""
    
    /// 필터 옵션
    @State private var filterOption: FilterOption = .all
    
    enum FilterOption: String, CaseIterable {
        case all = "전체"
        case granted = "허용됨"
        case denied = "거부됨"
        case pending = "대기 중"
        
        var iconName: String {
            switch self {
            case .all: return "list.bullet"
            case .granted: return "checkmark.circle.fill"
            case .denied: return "xmark.circle.fill"
            case .pending: return "questionmark.circle.fill"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // 필터 피커
                Section {
                    Picker("필터", selection: $filterOption) {
                        ForEach(FilterOption.allCases, id: \.self) { option in
                            Label(option.rawValue, systemImage: option.iconName)
                                .tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .listRowBackground(Color.clear)
                
                // 권한 목록
                Section {
                    ForEach(filteredPermissions) { permission in
                        PermissionRowView(permission: permission)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedPermission = permission
                            }
                    }
                } header: {
                    Text("\(filteredPermissions.count)개 권한")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("권한 목록")
            .searchable(text: $searchText, prompt: "권한 검색")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ForEach(FilterOption.allCases, id: \.self) { option in
                            Button {
                                filterOption = option
                            } label: {
                                Label(option.rawValue, systemImage: option.iconName)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
    }
    
    /// 필터링된 권한 목록
    private var filteredPermissions: [PermissionInfo] {
        var permissions = Array(permissionManager.permissions.values)
        
        // 상태 필터 적용
        switch filterOption {
        case .all:
            break
        case .granted:
            permissions = permissions.filter { $0.status.isGranted }
        case .denied:
            permissions = permissions.filter { $0.status == .denied || $0.status == .restricted }
        case .pending:
            permissions = permissions.filter { $0.status == .notDetermined }
        }
        
        // 검색 필터 적용
        if !searchText.isEmpty {
            permissions = permissions.filter {
                $0.displayName.localizedCaseInsensitiveContains(searchText) ||
                $0.usageDescription.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // 이름순 정렬
        return permissions.sorted { $0.displayName < $1.displayName }
    }
}

// MARK: - 권한 행 뷰
struct PermissionRowView: View {
    let permission: PermissionInfo
    @Environment(PermissionManager.self) private var permissionManager
    
    /// 요청 중 여부
    @State private var isRequesting = false
    
    var body: some View {
        HStack(spacing: 12) {
            // 권한 아이콘
            permissionIcon
            
            // 권한 정보
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(permission.displayName)
                        .font(.body.weight(.medium))
                    
                    if permission.isEssential {
                        Text("필수")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundStyle(.orange)
                            .clipShape(Capsule())
                    }
                }
                
                Text(permission.status.displayText)
                    .font(.caption)
                    .foregroundStyle(statusColor)
            }
            
            Spacer()
            
            // 액션 영역
            actionArea
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - 권한 아이콘
    private var permissionIcon: some View {
        ZStack {
            Circle()
                .fill(iconBackgroundColor.opacity(0.15))
                .frame(width: 44, height: 44)
            
            Image(systemName: permission.iconName)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(iconBackgroundColor)
        }
    }
    
    private var iconBackgroundColor: Color {
        switch permission.type.themeColor {
        case "systemBlue": return .blue
        case "systemRed": return .red
        case "systemGreen": return .green
        case "systemOrange": return .orange
        case "systemPurple": return .purple
        case "systemPink": return .pink
        case "systemYellow": return .yellow
        case "systemTeal": return .teal
        case "systemCyan": return .cyan
        case "systemIndigo": return .indigo
        case "systemMint": return .mint
        case "systemBrown": return .brown
        default: return .gray
        }
    }
    
    // MARK: - 액션 영역
    @ViewBuilder
    private var actionArea: some View {
        if isRequesting {
            ProgressView()
                .frame(width: 44)
        } else if permission.status.canRequest {
            Button {
                requestPermission()
            } label: {
                Text("요청")
                    .font(.subheadline.weight(.medium))
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.small)
        } else {
            Image(systemName: permission.status.iconName)
                .font(.title3)
                .foregroundStyle(statusColor)
        }
    }
    
    // MARK: - 상태 색상
    private var statusColor: Color {
        switch permission.status {
        case .authorized: return .green
        case .denied: return .red
        case .restricted: return .orange
        case .limited: return .yellow
        case .provisional: return .blue
        case .notDetermined: return .secondary
        case .unsupported: return .gray
        }
    }
    
    // MARK: - 권한 요청
    private func requestPermission() {
        isRequesting = true
        Task {
            _ = await permissionManager.requestPermission(for: permission.type)
            isRequesting = false
        }
    }
}

// MARK: - 그룹별 권한 뷰
struct GroupedPermissionView: View {
    @Environment(PermissionManager.self) private var permissionManager
    @Binding var selectedPermission: PermissionInfo?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(PermissionGroup.allCases) { group in
                    Section {
                        ForEach(permissionsInGroup(group)) { permission in
                            PermissionRowView(permission: permission)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedPermission = permission
                                }
                        }
                    } header: {
                        HStack {
                            Image(systemName: group.iconName)
                            Text(group.rawValue)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("그룹별 보기")
        }
    }
    
    private func permissionsInGroup(_ group: PermissionGroup) -> [PermissionInfo] {
        group.permissions.compactMap { permissionManager.permissions[$0] }
    }
}

// MARK: - 권한 상세 시트
struct PermissionDetailSheet: View {
    let permission: PermissionInfo
    @Environment(PermissionManager.self) private var permissionManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var isRequesting = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 헤더
                    headerSection
                    
                    // 상태 정보
                    statusSection
                    
                    // 사용 설명
                    usageDescriptionSection
                    
                    // 액션 버튼
                    actionSection
                }
                .padding()
            }
            .navigationTitle(permission.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - 헤더 섹션
    private var headerSection: some View {
        VStack(spacing: 16) {
            // 큰 아이콘
            ZStack {
                Circle()
                    .fill(themeColor.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: permission.iconName)
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(themeColor)
            }
            
            // 상태 배지
            HStack {
                Image(systemName: permission.status.iconName)
                Text(permission.status.displayText)
            }
            .font(.headline)
            .foregroundStyle(statusColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(statusColor.opacity(0.15))
            .clipShape(Capsule())
        }
    }
    
    private var themeColor: Color {
        switch permission.type.themeColor {
        case "systemBlue": return .blue
        case "systemRed": return .red
        case "systemGreen": return .green
        case "systemOrange": return .orange
        case "systemPurple": return .purple
        case "systemPink": return .pink
        default: return .blue
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
    
    // MARK: - 상태 섹션
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("상태 정보")
                .font(.headline)
            
            VStack(spacing: 8) {
                DetailRow(label: "현재 상태", value: permission.status.displayText)
                DetailRow(label: "마지막 확인", value: formattedDate(permission.lastChecked))
                DetailRow(label: "변경 횟수", value: "\(permission.changeCount)회")
                DetailRow(label: "필수 권한", value: permission.isEssential ? "예" : "아니오")
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.regularMaterial)
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    // MARK: - 사용 설명 섹션
    private var usageDescriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("사용 목적")
                .font(.headline)
            
            Text(permission.usageDescription)
                .font(.body)
                .foregroundStyle(.secondary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.regularMaterial)
                }
            
            if permission.status.requiresSettings {
                VStack(alignment: .leading, spacing: 8) {
                    Label("설정에서 변경 필요", systemImage: "exclamationmark.triangle.fill")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.orange)
                    
                    Text(permission.status.detailedDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.orange.opacity(0.1))
                }
            }
        }
    }
    
    // MARK: - 액션 섹션
    private var actionSection: some View {
        VStack(spacing: 12) {
            if permission.status.canRequest {
                Button {
                    requestPermission()
                } label: {
                    if isRequesting {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("권한 요청하기")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(isRequesting)
            }
            
            if permission.status.requiresSettings {
                Button {
                    SettingsHelper.openAppSettings()
                } label: {
                    Label("설정 앱에서 변경", systemImage: "gear")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
    }
    
    private func requestPermission() {
        isRequesting = true
        Task {
            _ = await permissionManager.requestPermission(for: permission.type)
            isRequesting = false
        }
    }
}

// MARK: - 상세 정보 행
struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

// MARK: - 변경 이력 뷰
struct ChangeHistoryView: View {
    @Environment(PermissionManager.self) private var permissionManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Group {
                if permissionManager.changeHistory.isEmpty {
                    ContentUnavailableView(
                        "변경 이력 없음",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("권한 변경 이력이 여기에 표시됩니다.")
                    )
                } else {
                    List(permissionManager.changeHistory) { event in
                        HistoryEventRow(event: event)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("변경 이력")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
                
                if !permissionManager.changeHistory.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("초기화") {
                            permissionManager.clearChangeHistory()
                        }
                        .foregroundStyle(.red)
                    }
                }
            }
        }
    }
}

// MARK: - 이력 이벤트 행
struct HistoryEventRow: View {
    let event: PermissionChangeEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: event.permissionType.iconName)
                    .foregroundStyle(.blue)
                
                Text(event.permissionType.displayName)
                    .font(.headline)
                
                Spacer()
                
                Text(formattedTime)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                StatusBadge(status: event.previousStatus)
                
                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                StatusBadge(status: event.newStatus)
            }
            
            Text("출처: \(event.source.rawValue)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: event.timestamp)
    }
}

// MARK: - 상태 배지
struct StatusBadge: View {
    let status: PermissionStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.iconName)
            Text(status.displayText)
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor.opacity(0.15))
        .foregroundStyle(statusColor)
        .clipShape(Capsule())
    }
    
    private var statusColor: Color {
        switch status {
        case .authorized: return .green
        case .denied: return .red
        case .notDetermined: return .orange
        default: return .secondary
        }
    }
}

// MARK: - 설정 뷰
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PermissionManager.self) private var permissionManager
    
    var body: some View {
        NavigationStack {
            List {
                Section("앱 정보") {
                    HStack {
                        Text("버전")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("PermissionKit 버전")
                        Spacer()
                        Text(PermissionConfiguration.frameworkVersion ?? "N/A")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("권한 통계") {
                    HStack {
                        Text("전체 권한")
                        Spacer()
                        Text("\(PermissionType.allCases.count)개")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("허용률")
                        Spacer()
                        Text("\(Int(permissionManager.overallGrantedRatio * 100))%")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section {
                    Button {
                        SettingsHelper.openAppSettings()
                    } label: {
                        Label("시스템 설정 열기", systemImage: "gear")
                    }
                }
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview("권한 목록") {
    PermissionListView(selectedPermission: .constant(nil))
        .environment(PermissionManager())
}

#Preview("권한 상세") {
    PermissionDetailSheet(
        permission: PermissionInfo(type: .camera, status: .authorized)
    )
    .environment(PermissionManager())
}
