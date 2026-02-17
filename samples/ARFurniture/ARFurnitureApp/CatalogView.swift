//
//  CatalogView.swift
//  ARFurniture
//
//  가구 카탈로그 뷰 - 가구 선택 인터페이스
//

import SwiftUI

/// 가구 카탈로그 뷰
struct CatalogView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var arManager: ARManager
    @Environment(\.dismiss) var dismiss
    
    /// 선택된 카테고리
    @Binding var selectedCategory: FurnitureCategory
    
    /// 검색어
    @State private var searchText = ""
    
    /// 상세 정보 표시할 가구
    @State private var detailItem: FurnitureItem?
    
    // MARK: - Computed Properties
    
    /// 필터링된 가구 목록
    private var filteredItems: [FurnitureItem] {
        let categoryFiltered = FurnitureItem.sampleItems.filter {
            $0.category == selectedCategory
        }
        
        if searchText.isEmpty {
            return categoryFiltered
        }
        
        return categoryFiltered.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 카테고리 탭
                categoryTabs
                
                // 가구 그리드
                furnitureGrid
            }
            .navigationTitle("가구 카탈로그")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
            .searchable(text: $searchText, prompt: "가구 검색")
        }
        .sheet(item: $detailItem) { item in
            FurnitureDetailView(item: item) {
                selectFurniture(item)
            }
        }
    }
    
    // MARK: - Category Tabs
    
    /// 카테고리 탭 바
    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(FurnitureCategory.allCases) { category in
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
            .padding(.vertical, 12)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Furniture Grid
    
    /// 가구 그리드
    private var furnitureGrid: some View {
        ScrollView {
            if filteredItems.isEmpty {
                emptyState
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ],
                    spacing: 16
                ) {
                    ForEach(filteredItems) { item in
                        FurnitureCard(item: item) {
                            detailItem = item
                        } onSelect: {
                            selectFurniture(item)
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    /// 빈 상태 뷰
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "cube.transparent")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("가구가 없습니다")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if !searchText.isEmpty {
                Text("다른 검색어를 시도해보세요")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
    
    // MARK: - Actions
    
    /// 가구 선택
    private func selectFurniture(_ item: FurnitureItem) {
        arManager.selectedFurniture = item
        dismiss()
    }
}

// MARK: - Category Tab

/// 카테고리 탭 버튼
struct CategoryTab: View {
    let category: FurnitureCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: category.iconName)
                    .font(.title2)
                
                Text(category.rawValue)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                isSelected
                    ? AnyShapeStyle(LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    : AnyShapeStyle(Color(.secondarySystemBackground))
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Furniture Card

/// 가구 카드 뷰
struct FurnitureCard: View {
    
    let item: FurnitureItem
    let onDetail: () -> Void
    let onSelect: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 썸네일
            thumbnailView
            
            // 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                
                Text(item.formattedPrice)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            
            // 버튼
            HStack(spacing: 8) {
                // 상세 버튼
                Button {
                    onDetail()
                } label: {
                    Image(systemName: "info.circle")
                        .font(.subheadline)
                }
                .buttonStyle(.bordered)
                
                // 선택 버튼
                Button {
                    onSelect()
                } label: {
                    Text("배치")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    /// 썸네일 뷰
    private var thumbnailView: some View {
        ZStack {
            // 배경
            LinearGradient(
                colors: [
                    Color(.systemGray5),
                    Color(.systemGray6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 아이콘 (실제 앱에서는 Image로 대체)
            Image(systemName: item.category.iconName)
                .font(.system(size: 40))
                .foregroundColor(.secondary)
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(8)
    }
}

// MARK: - Furniture Detail View

/// 가구 상세 정보 뷰
struct FurnitureDetailView: View {
    
    let item: FurnitureItem
    let onSelect: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 썸네일
                    thumbnailSection
                    
                    // 기본 정보
                    infoSection
                    
                    // 크기 정보
                    dimensionSection
                    
                    // 설명
                    if !item.description.isEmpty {
                        descriptionSection
                    }
                    
                    // 배치 버튼
                    selectButton
                }
                .padding()
            }
            .navigationTitle(item.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    /// 썸네일 섹션
    private var thumbnailSection: some View {
        ZStack {
            LinearGradient(
                colors: [Color(.systemGray5), Color(.systemGray6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Image(systemName: item.category.iconName)
                .font(.system(size: 80))
                .foregroundColor(.secondary)
        }
        .aspectRatio(1.5, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    /// 정보 섹션
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // 카테고리
                Label(item.category.rawValue, systemImage: item.category.iconName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // 가격
                Text(item.formattedPrice)
                    .font(.title2.bold())
                    .foregroundColor(.primary)
            }
        }
    }
    
    /// 크기 섹션
    private var dimensionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("크기")
                .font(.headline)
            
            Text(item.formattedDimensions)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    /// 설명 섹션
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("설명")
                .font(.headline)
            
            Text(item.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    /// 배치 버튼
    private var selectButton: some View {
        Button {
            onSelect()
            dismiss()
        } label: {
            HStack {
                Image(systemName: "cube.fill")
                Text("AR로 배치하기")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - Preview

#Preview {
    CatalogView(selectedCategory: .constant(.chair))
        .environmentObject(ARManager())
}
