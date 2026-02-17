// PresetGalleryView.swift
// HapticDemo - Core Haptics 샘플
// 프리셋 갤러리 - 미리 정의된 햅틱 패턴 탐색

import SwiftUI

// MARK: - 프리셋 갤러리 뷰
struct PresetGalleryView: View {
    @EnvironmentObject var hapticManager: HapticEngineManager
    @State private var selectedCategory: PatternCategory = .basic
    @State private var searchText: String = ""
    @State private var showingPresetDetail: HapticPreset?
    
    /// 검색 및 카테고리 필터링된 프리셋
    var filteredPresets: [HapticPreset] {
        var presets = PresetLibrary.presets(for: selectedCategory)
        
        if !searchText.isEmpty {
            presets = presets.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return presets
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 카테고리 선택기
                categoryPicker
                
                // 프리셋 그리드
                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: 16) {
                        ForEach(filteredPresets) { preset in
                            PresetCard(preset: preset) {
                                playPreset(preset)
                            }
                            .onLongPressGesture {
                                showingPresetDetail = preset
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("프리셋 갤러리")
            .searchable(text: $searchText, prompt: "패턴 검색")
            .sheet(item: $showingPresetDetail) { preset in
                PresetDetailSheet(preset: preset)
            }
        }
    }
    
    // MARK: - 카테고리 선택기
    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(PatternCategory.allCases) { category in
                    CategoryChip(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = category
                        }
                        // 카테고리 선택 시 햅틱 피드백
                        hapticManager.playTransientHaptic(intensity: 0.5, sharpness: 0.7)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - 그리드 레이아웃
    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
    }
    
    // MARK: - 프리셋 재생
    private func playPreset(_ preset: HapticPreset) {
        do {
            try hapticManager.playPreset(preset)
        } catch {
            // 에러 처리
        }
    }
}

// MARK: - 카테고리 칩
struct CategoryChip: View {
    let category: PatternCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.iconName)
                    .font(.caption)
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? categoryColor : Color(.tertiarySystemFill))
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
    
    private var categoryColor: Color {
        switch category.color {
        case "blue": return .blue
        case "orange": return .orange
        case "purple": return .purple
        case "green": return .green
        case "pink": return .pink
        default: return .blue
        }
    }
}

// MARK: - 프리셋 카드
struct PresetCard: View {
    let preset: HapticPreset
    let action: () -> Void
    
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // 아이콘
                ZStack {
                    Circle()
                        .fill(cardColor.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: preset.iconName)
                        .font(.title2)
                        .foregroundColor(cardColor)
                }
                
                // 텍스트
                VStack(spacing: 4) {
                    Text(preset.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(preset.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = pressing
            }
        }, perform: {})
    }
    
    private var cardColor: Color {
        switch preset.previewColor {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "purple": return .purple
        case "pink": return .pink
        case "cyan": return .cyan
        case "brown": return .brown
        case "yellow": return .yellow
        case "teal": return .teal
        case "mint": return .mint
        case "indigo": return .indigo
        default: return .blue
        }
    }
}

// MARK: - 프리셋 상세 시트
struct PresetDetailSheet: View {
    @EnvironmentObject var hapticManager: HapticEngineManager
    @Environment(\.dismiss) var dismiss
    let preset: HapticPreset
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 헤더
                    headerSection
                    
                    // 패턴 정보
                    patternInfoSection
                    
                    // 이벤트 목록
                    eventsSection
                    
                    // 재생 버튼
                    playButton
                }
                .padding()
            }
            .navigationTitle("패턴 상세")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") { dismiss() }
                }
            }
        }
    }
    
    // MARK: - 헤더 섹션
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: preset.iconName)
                    .font(.largeTitle)
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 4) {
                Text(preset.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(preset.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // 카테고리 배지
            Text(preset.category.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .clipShape(Capsule())
        }
    }
    
    // MARK: - 패턴 정보 섹션
    private var patternInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("패턴 정보")
                .font(.headline)
            
            HStack {
                InfoCard(title: "이벤트 수", value: "\(preset.pattern.events.count)개")
                InfoCard(title: "총 길이", value: String(format: "%.2f초", preset.pattern.totalDuration))
            }
            
            HStack {
                InfoCard(title: "루핑", value: preset.pattern.isLooping ? "예" : "아니오")
                if preset.pattern.isLooping {
                    InfoCard(title: "루프 길이", value: String(format: "%.2f초", preset.pattern.loopDuration))
                }
            }
        }
    }
    
    // MARK: - 이벤트 목록 섹션
    private var eventsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("이벤트 목록")
                .font(.headline)
            
            ForEach(preset.pattern.sortedEvents) { event in
                EventRow(event: event)
            }
        }
    }
    
    // MARK: - 재생 버튼
    private var playButton: some View {
        Button {
            try? hapticManager.playPreset(preset)
        } label: {
            Label("재생하기", systemImage: "play.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.top)
    }
}

// MARK: - 정보 카드
struct InfoCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.tertiarySystemFill))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - 이벤트 행
struct EventRow: View {
    let event: HapticEvent
    
    var body: some View {
        HStack {
            Image(systemName: event.type.iconName)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(event.type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("시간: \(String(format: "%.2f초", event.relativeTime))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("강도: \(Int(event.intensity * 100))%")
                    .font(.caption)
                Text("선명도: \(Int(event.sharpness * 100))%")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    PresetGalleryView()
        .environmentObject(HapticEngineManager())
}
