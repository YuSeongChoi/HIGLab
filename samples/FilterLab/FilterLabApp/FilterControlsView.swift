// FilterControlsView.swift
// FilterLab - 필터 컨트롤 뷰
// HIG Lab 샘플 프로젝트

import SwiftUI

// MARK: - 필터 컨트롤 뷰
struct FilterControlsView: View {
    let appState: AppState
    
    @State private var selectedNodeId: UUID?
    @State private var isExpanded: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            controlHeader
            
            if isExpanded {
                // 필터 체인 리스트
                filterChainList
                
                // 선택된 필터의 강도 조절
                if let nodeId = selectedNodeId,
                   let node = appState.filterChain.nodes.first(where: { $0.id == nodeId }) {
                    IntensitySlider(
                        node: node,
                        onChange: { newIntensity in
                            appState.filterChain.updateIntensity(id: nodeId, intensity: newIntensity)
                            Task {
                                await appState.processor.applyFilters(chain: appState.filterChain)
                            }
                        }
                    )
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - 컨트롤 헤더
    private var controlHeader: some View {
        HStack {
            // 확장/축소 버튼
            Button {
                withAnimation(.spring(response: 0.3)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "slider.horizontal.3")
                    Text("필터")
                        .fontWeight(.semibold)
                    
                    if !appState.filterChain.isEmpty {
                        Text("\(appState.filterChain.activeNodes.count)/\(appState.filterChain.nodes.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .foregroundStyle(.primary)
            
            // 필터 추가 버튼
            Button {
                appState.showFilterPicker = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
            }
        }
        .padding()
    }
    
    // MARK: - 필터 체인 리스트
    private var filterChainList: some View {
        Group {
            if appState.filterChain.isEmpty {
                emptyChainView
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(appState.filterChain.nodes.enumerated()), id: \.element.id) { index, node in
                            FilterChainItem(
                                node: node,
                                index: index,
                                isSelected: selectedNodeId == node.id,
                                onSelect: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedNodeId = selectedNodeId == node.id ? nil : node.id
                                    }
                                },
                                onToggle: {
                                    appState.filterChain.toggleFilter(id: node.id)
                                    Task {
                                        await appState.processor.applyFilters(chain: appState.filterChain)
                                    }
                                },
                                onRemove: {
                                    withAnimation {
                                        if selectedNodeId == node.id {
                                            selectedNodeId = nil
                                        }
                                        appState.filterChain.removeFilter(id: node.id)
                                    }
                                    Task {
                                        await appState.processor.applyFilters(chain: appState.filterChain)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }
        }
        .frame(height: appState.filterChain.isEmpty ? 80 : 100)
    }
    
    // MARK: - 빈 체인 뷰
    private var emptyChainView: some View {
        VStack(spacing: 8) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.title2)
                .foregroundStyle(.secondary)
            
            Text("필터를 추가해보세요")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 필터 체인 아이템
struct FilterChainItem: View {
    let node: FilterNode
    let index: Int
    let isSelected: Bool
    let onSelect: () -> Void
    let onToggle: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        VStack(spacing: 6) {
            // 필터 카드
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(node.isEnabled ? 
                          Color.accentColor.opacity(0.15) : 
                          Color(.systemGray5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                isSelected ? Color.accentColor : Color.clear,
                                lineWidth: 2
                            )
                    )
                
                VStack(spacing: 4) {
                    Image(systemName: node.filterType.category.icon)
                        .font(.title3)
                        .foregroundStyle(node.isEnabled ? .primary : .secondary)
                    
                    Text(node.filterType.rawValue)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .foregroundStyle(node.isEnabled ? .primary : .secondary)
                }
                .padding(8)
            }
            .frame(width: 70, height: 60)
            .onTapGesture {
                onSelect()
            }
            .onLongPressGesture {
                onToggle()
            }
            .contextMenu {
                Button {
                    onToggle()
                } label: {
                    Label(
                        node.isEnabled ? "비활성화" : "활성화",
                        systemImage: node.isEnabled ? "eye.slash" : "eye"
                    )
                }
                
                Button(role: .destructive) {
                    onRemove()
                } label: {
                    Label("제거", systemImage: "trash")
                }
            }
            
            // 순서 표시
            Text("\(index + 1)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - 강도 슬라이더
struct IntensitySlider: View {
    let node: FilterNode
    let onChange: (Float) -> Void
    
    @State private var intensity: Float
    @State private var isDragging: Bool = false
    
    init(node: FilterNode, onChange: @escaping (Float) -> Void) {
        self.node = node
        self.onChange = onChange
        self._intensity = State(initialValue: node.intensity)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 헤더
            HStack {
                Text(node.filterType.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(formattedValue)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            
            // 슬라이더
            if node.filterType.hasIntensity {
                HStack(spacing: 16) {
                    // 최소값 버튼
                    Button {
                        setIntensity(node.filterType.intensityRange.min)
                    } label: {
                        Image(systemName: "minus.circle")
                            .foregroundStyle(.secondary)
                    }
                    
                    // 슬라이더
                    Slider(
                        value: $intensity,
                        in: node.filterType.intensityRange.min...node.filterType.intensityRange.max,
                        onEditingChanged: { editing in
                            isDragging = editing
                            if !editing {
                                onChange(intensity)
                            }
                        }
                    )
                    .tint(.accentColor)
                    .onChange(of: intensity) { _, newValue in
                        // 드래그 중에는 실시간 업데이트 (디바운스 적용 가능)
                        if isDragging {
                            // 성능을 위해 일정 간격으로만 업데이트
                        }
                    }
                    
                    // 최대값 버튼
                    Button {
                        setIntensity(node.filterType.intensityRange.max)
                    } label: {
                        Image(systemName: "plus.circle")
                            .foregroundStyle(.secondary)
                    }
                    
                    // 리셋 버튼
                    Button {
                        setIntensity(node.filterType.intensityRange.defaultValue)
                    } label: {
                        Image(systemName: "arrow.counterclockwise.circle")
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Text("이 필터는 강도 조절을 지원하지 않습니다")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var formattedValue: String {
        let range = node.filterType.intensityRange
        
        // 각도인 경우 도(degree)로 표시
        if node.filterType == .hueAdjust {
            return String(format: "%.0f°", intensity * 180 / Float.pi)
        }
        
        // 픽셀/반경인 경우 정수로 표시
        if range.max > 10 {
            return String(format: "%.0f", intensity)
        }
        
        // 그 외에는 퍼센트로 표시
        let normalized = (intensity - range.min) / (range.max - range.min)
        return String(format: "%.0f%%", normalized * 100)
    }
    
    private func setIntensity(_ value: Float) {
        withAnimation(.easeInOut(duration: 0.2)) {
            intensity = value
        }
        onChange(value)
    }
}

// MARK: - 퀵 필터 그리드
struct QuickFilterGrid: View {
    let appState: AppState
    let category: FilterCategory
    
    private var filters: [FilterType] {
        FilterType.allCases.filter { $0.category == category }
    }
    
    private let columns = [
        GridItem(.adaptive(minimum: 80), spacing: 12)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(filters) { filterType in
                QuickFilterButton(filterType: filterType) {
                    appState.filterChain.addFilter(filterType)
                    Task {
                        await appState.processor.applyFilters(chain: appState.filterChain)
                    }
                }
            }
        }
        .padding()
    }
}

// MARK: - 퀵 필터 버튼
struct QuickFilterButton: View {
    let filterType: FilterType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: filterType.category.icon)
                    .font(.title2)
                
                Text(filterType.rawValue)
                    .font(.caption2)
                    .lineLimit(1)
            }
            .frame(width: 70, height: 60)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 카테고리 탭 바
struct CategoryTabBar: View {
    @Binding var selectedCategory: FilterCategory
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FilterCategory.allCases) { category in
                    CategoryTab(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - 카테고리 탭
struct CategoryTab: View {
    let category: FilterCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                Text(category.rawValue)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .font(.subheadline)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color(.secondarySystemGroupedBackground))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 프리뷰
#Preview {
    VStack {
        Spacer()
        FilterControlsView(appState: {
            let state = AppState()
            state.filterChain.addFilter(.sepiaTone)
            state.filterChain.addFilter(.vignette)
            state.filterChain.addFilter(.gaussianBlur)
            return state
        }())
    }
}
