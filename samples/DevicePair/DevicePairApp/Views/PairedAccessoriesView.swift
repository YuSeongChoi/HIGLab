//
//  PairedAccessoriesView.swift
//  DevicePair
//
//  페어링된 액세서리 목록 - 연결된 모든 기기를 관리
//

import SwiftUI

// MARK: - 페어링된 액세서리 뷰

/// 사용자의 페어링된 액세서리를 표시하고 관리하는 뷰
struct PairedAccessoriesView: View {
    
    @EnvironmentObject private var sessionManager: AccessorySessionManager
    
    /// 카테고리별 필터링 옵션
    @State private var selectedCategory: AccessoryCategory?
    
    /// 검색 텍스트
    @State private var searchText = ""
    
    /// 정렬 옵션
    @State private var sortOption: SortOption = .name
    
    /// 상세 시트 표시 여부
    @State private var showingDetail = false
    
    /// 선택된 액세서리 (상세 보기용)
    @State private var detailAccessory: Accessory?
    
    var body: some View {
        NavigationStack {
            Group {
                if sessionManager.pairedAccessories.isEmpty {
                    emptyStateView
                } else {
                    accessoryListView
                }
            }
            .navigationTitle("내 기기")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    sortMenu
                }
            }
            .searchable(text: $searchText, prompt: "기기 검색")
            .sheet(item: $detailAccessory) { accessory in
                NavigationStack {
                    AccessoryDetailView(accessory: accessory)
                }
            }
        }
    }
    
    // MARK: - 빈 상태 뷰
    
    /// 페어링된 기기가 없을 때 표시
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("기기 없음", systemImage: "rectangle.stack.badge.plus")
        } description: {
            Text("아직 페어링된 기기가 없습니다.\n'기기 추가' 탭에서 새 기기를 추가하세요.")
        }
    }
    
    // MARK: - 액세서리 목록 뷰
    
    /// 필터링 및 정렬된 액세서리 목록
    private var filteredAccessories: [Accessory] {
        var result = sessionManager.pairedAccessories
        
        // 카테고리 필터
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        // 검색 필터
        if !searchText.isEmpty {
            result = result.filter { accessory in
                accessory.name.localizedCaseInsensitiveContains(searchText) ||
                accessory.manufacturer.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // 정렬
        switch sortOption {
        case .name:
            result.sort { $0.name < $1.name }
        case .category:
            result.sort { $0.category.rawValue < $1.category.rawValue }
        case .connectionState:
            result.sort { $0.connectionState.rawValue < $1.connectionState.rawValue }
        case .lastConnected:
            result.sort { ($0.lastConnected ?? .distantPast) > ($1.lastConnected ?? .distantPast) }
        }
        
        return result
    }
    
    private var accessoryListView: some View {
        List {
            // 연결 상태 요약
            connectionSummarySection
            
            // 카테고리 필터
            categoryFilterSection
            
            // 액세서리 목록
            accessoriesSection
        }
        .listStyle(.insetGrouped)
        .refreshable {
            // 새로고침 시 연결 상태 업데이트
            await refreshAccessories()
        }
    }
    
    // MARK: - 연결 상태 요약
    
    private var connectionSummarySection: some View {
        Section {
            HStack(spacing: 20) {
                ConnectionStatBadge(
                    count: sessionManager.connectedCount,
                    label: "연결됨",
                    color: .green
                )
                
                ConnectionStatBadge(
                    count: sessionManager.pairedAccessories.count - sessionManager.connectedCount,
                    label: "연결 안 됨",
                    color: .gray
                )
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - 카테고리 필터
    
    private var categoryFilterSection: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    // 전체 보기 버튼
                    CategoryFilterChip(
                        title: "전체",
                        icon: "square.grid.2x2.fill",
                        isSelected: selectedCategory == nil,
                        color: .blue
                    ) {
                        selectedCategory = nil
                    }
                    
                    // 카테고리별 필터 버튼
                    ForEach(usedCategories, id: \.self) { category in
                        CategoryFilterChip(
                            title: category.rawValue,
                            icon: category.iconName,
                            isSelected: selectedCategory == category,
                            color: category.color
                        ) {
                            selectedCategory = selectedCategory == category ? nil : category
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
    }
    
    /// 사용 중인 카테고리만 반환
    private var usedCategories: [AccessoryCategory] {
        Array(Set(sessionManager.pairedAccessories.map(\.category))).sorted { $0.rawValue < $1.rawValue }
    }
    
    // MARK: - 액세서리 섹션
    
    private var accessoriesSection: some View {
        Section {
            ForEach(filteredAccessories) { accessory in
                AccessoryRowView(accessory: accessory) {
                    detailAccessory = accessory
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        sessionManager.unpairAccessory(accessory)
                    } label: {
                        Label("해제", systemImage: "trash")
                    }
                    
                    if accessory.connectionState == .connected {
                        Button {
                            sessionManager.disconnectAccessory(accessory)
                        } label: {
                            Label("연결 해제", systemImage: "wifi.slash")
                        }
                        .tint(.orange)
                    }
                }
                .swipeActions(edge: .leading) {
                    if accessory.connectionState == .disconnected {
                        Button {
                            sessionManager.reconnectAccessory(accessory)
                        } label: {
                            Label("연결", systemImage: "wifi")
                        }
                        .tint(.green)
                    }
                }
            }
        } header: {
            Text("기기 \(filteredAccessories.count)개")
        }
    }
    
    // MARK: - 정렬 메뉴
    
    private var sortMenu: some View {
        Menu {
            ForEach(SortOption.allCases, id: \.self) { option in
                Button {
                    sortOption = option
                } label: {
                    HStack {
                        Text(option.rawValue)
                        if sortOption == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
        }
    }
    
    // MARK: - 새로고침
    
    private func refreshAccessories() async {
        // 각 연결 안 된 액세서리 재연결 시도
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }
}

// MARK: - 정렬 옵션

enum SortOption: String, CaseIterable {
    case name = "이름순"
    case category = "카테고리순"
    case connectionState = "연결 상태순"
    case lastConnected = "최근 연결순"
}

// MARK: - 연결 상태 배지

struct ConnectionStatBadge: View {
    let count: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title2.bold())
                .foregroundStyle(color)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 60)
    }
}

// MARK: - 카테고리 필터 칩

struct CategoryFilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption.weight(.medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected ? color.opacity(0.2) : Color(.systemGray6)
            )
            .foregroundStyle(isSelected ? color : .primary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? color : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 액세서리 행 뷰

struct AccessoryRowView: View {
    let accessory: Accessory
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // 카테고리 아이콘
                ZStack {
                    Circle()
                        .fill(accessory.category.color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: accessory.category.iconName)
                        .font(.system(size: 18))
                        .foregroundStyle(accessory.category.color)
                }
                
                // 기기 정보
                VStack(alignment: .leading, spacing: 4) {
                    Text(accessory.name)
                        .font(.body.weight(.medium))
                        .foregroundStyle(.primary)
                    
                    HStack(spacing: 6) {
                        // 연결 상태
                        HStack(spacing: 4) {
                            Image(systemName: accessory.connectionState.iconName)
                                .font(.caption2)
                            Text(accessory.connectionState.rawValue)
                                .font(.caption)
                        }
                        .foregroundStyle(connectionColor)
                        
                        // 배터리 (있는 경우)
                        if let battery = accessory.batteryLevel {
                            Text("•")
                                .foregroundStyle(.secondary)
                            HStack(spacing: 3) {
                                Image(systemName: batteryIcon(for: battery))
                                    .font(.caption2)
                                Text("\(battery)%")
                                    .font(.caption)
                            }
                            .foregroundStyle(batteryColor(for: battery))
                        }
                    }
                }
                
                Spacer()
                
                // 연결 중 인디케이터
                if accessory.connectionState == .connecting {
                    ProgressView()
                        .scaleEffect(0.8)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
    
    private var connectionColor: Color {
        switch accessory.connectionState {
        case .connected: return .green
        case .connecting: return .orange
        case .disconnected: return .secondary
        case .failed: return .red
        }
    }
    
    private func batteryIcon(for level: Int) -> String {
        switch level {
        case 0..<20: return "battery.0percent"
        case 20..<50: return "battery.25percent"
        case 50..<75: return "battery.50percent"
        case 75..<100: return "battery.75percent"
        default: return "battery.100percent"
        }
    }
    
    private func batteryColor(for level: Int) -> Color {
        switch level {
        case 0..<20: return .red
        case 20..<50: return .orange
        default: return .secondary
        }
    }
}

// MARK: - 미리보기

#Preview {
    PairedAccessoriesView()
        .environmentObject(AccessorySessionManager())
}
