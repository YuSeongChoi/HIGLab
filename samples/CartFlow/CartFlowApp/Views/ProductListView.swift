import SwiftUI

// MARK: - 상품 목록 뷰
/// 쇼핑 앱의 메인 상품 목록 화면
///
/// ## 주요 기능
/// - 카테고리별 필터링
/// - 상품 검색
/// - 그리드/리스트 레이아웃 전환
/// - 장바구니 추가
///
/// ## 접근성
/// - VoiceOver 완벽 지원
/// - Dynamic Type 대응
/// - 애니메이션 감소 지원

struct ProductListView: View {
    
    // MARK: - 환경
    
    @Environment(CartStore.self) private var cartStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - 상태
    
    /// 상품 목록
    @State private var products: [Product] = []
    
    /// 로딩 중 여부
    @State private var isLoading = true
    
    /// 선택된 카테고리
    @State private var selectedCategory: ProductCategory?
    
    /// 검색어
    @State private var searchText = ""
    
    /// 레이아웃 모드
    @State private var layoutMode: LayoutMode = .grid
    
    /// 에러 메시지
    @State private var errorMessage: String?
    
    /// 정렬 기준
    @State private var sortOrder: SortOrder = .default
    
    /// 추가됨 토스트 표시
    @State private var showAddedToast = false
    @State private var addedProductName = ""
    
    // MARK: - 레이아웃 모드
    
    enum LayoutMode: String, CaseIterable {
        case grid = "그리드"
        case list = "리스트"
        
        var icon: String {
            switch self {
            case .grid: return "square.grid.2x2"
            case .list: return "list.bullet"
            }
        }
    }
    
    // MARK: - 정렬 기준
    
    enum SortOrder: String, CaseIterable {
        case `default` = "기본"
        case priceAsc = "가격 낮은순"
        case priceDesc = "가격 높은순"
        case name = "이름순"
        
        var icon: String {
            switch self {
            case .default: return "arrow.up.arrow.down"
            case .priceAsc: return "arrow.up"
            case .priceDesc: return "arrow.down"
            case .name: return "textformat.abc"
            }
        }
    }
    
    // MARK: - 필터링된 상품
    
    private var filteredProducts: [Product] {
        var result = products
        
        // 카테고리 필터
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        // 검색 필터
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter { product in
                product.name.lowercased().contains(query) ||
                product.description.lowercased().contains(query)
            }
        }
        
        // 정렬
        switch sortOrder {
        case .default:
            break
        case .priceAsc:
            result.sort { $0.price < $1.price }
        case .priceDesc:
            result.sort { $0.price > $1.price }
        case .name:
            result.sort { $0.name < $1.name }
        }
        
        return result
    }
    
    // MARK: - 그리드 레이아웃
    
    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
    }
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if isLoading {
                loadingView
            } else if let error = errorMessage {
                errorView(message: error)
            } else if filteredProducts.isEmpty {
                emptyView
            } else {
                productScrollView
            }
        }
        .navigationTitle("CartFlow")
        .searchable(text: $searchText, prompt: "상품 검색")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                layoutToggleButton
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                sortMenu
            }
        }
        .overlay(alignment: .bottom) {
            if showAddedToast {
                addedToastView
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .task {
            await loadProducts()
        }
        .refreshable {
            await loadProducts()
        }
    }
    
    // MARK: - 로딩 뷰
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
            
            Text("상품을 불러오는 중...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - 에러 뷰
    
    private func errorView(message: String) -> some View {
        ContentUnavailableView {
            Label("오류 발생", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("다시 시도") {
                Task { await loadProducts() }
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    // MARK: - 빈 상태 뷰
    
    private var emptyView: some View {
        ContentUnavailableView {
            Label("검색 결과 없음", systemImage: "magnifyingglass")
        } description: {
            Text("'\(searchText)'에 대한 검색 결과가 없습니다.")
        } actions: {
            Button("검색어 지우기") {
                searchText = ""
            }
            .buttonStyle(.bordered)
        }
    }
    
    // MARK: - 상품 스크롤 뷰
    
    private var productScrollView: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 카테고리 필터
                categoryFilterView
                
                // 상품 목록
                switch layoutMode {
                case .grid:
                    gridView
                case .list:
                    listView
                }
            }
            .padding()
        }
    }
    
    // MARK: - 카테고리 필터
    
    private var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // 전체 버튼
                CategoryChip(
                    title: "전체",
                    icon: "square.grid.2x2",
                    isSelected: selectedCategory == nil,
                    action: { selectedCategory = nil }
                )
                
                // 카테고리 버튼들
                ForEach(ProductCategory.allCases) { category in
                    CategoryChip(
                        title: category.rawValue,
                        icon: category.symbol,
                        isSelected: selectedCategory == category,
                        action: { selectedCategory = category }
                    )
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("카테고리 필터")
    }
    
    // MARK: - 그리드 뷰
    
    private var gridView: some View {
        LazyVGrid(columns: gridColumns, spacing: 16) {
            ForEach(filteredProducts) { product in
                ProductGridCell(product: product) {
                    addToCart(product)
                }
            }
        }
    }
    
    // MARK: - 리스트 뷰
    
    private var listView: some View {
        LazyVStack(spacing: 12) {
            ForEach(filteredProducts) { product in
                ProductListRow(product: product) {
                    addToCart(product)
                }
            }
        }
    }
    
    // MARK: - 레이아웃 토글 버튼
    
    private var layoutToggleButton: some View {
        Button {
            withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.2)) {
                layoutMode = layoutMode == .grid ? .list : .grid
            }
        } label: {
            Image(systemName: layoutMode == .grid ? "list.bullet" : "square.grid.2x2")
        }
        .accessibilityLabel("레이아웃 변경")
        .accessibilityHint("현재 \(layoutMode.rawValue), 탭하여 변경")
    }
    
    // MARK: - 정렬 메뉴
    
    private var sortMenu: some View {
        Menu {
            ForEach(SortOrder.allCases, id: \.self) { order in
                Button {
                    sortOrder = order
                } label: {
                    Label(order.rawValue, systemImage: order.icon)
                    if sortOrder == order {
                        Image(systemName: "checkmark")
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down.circle")
        }
        .accessibilityLabel("정렬 기준")
        .accessibilityHint("현재 \(sortOrder.rawValue)")
    }
    
    // MARK: - 추가됨 토스트
    
    private var addedToastView: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            
            Text("\(addedProductName) 장바구니에 추가됨")
                .font(.subheadline)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: Capsule())
        .shadow(color: .black.opacity(0.1), radius: 10)
        .padding(.bottom, 16)
    }
    
    // MARK: - 액션
    
    /// 상품 로드
    private func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            products = try await ProductService.shared.fetchAllProducts()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// 장바구니에 추가
    private func addToCart(_ product: Product) {
        cartStore.addToCart(product)
        
        // 토스트 표시
        addedProductName = product.name
        withAnimation {
            showAddedToast = true
        }
        
        // 토스트 숨기기
        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation {
                showAddedToast = false
            }
        }
    }
}

// MARK: - 카테고리 칩

struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    isSelected ? Color.accentColor : Color(.systemGray5),
                    in: Capsule()
                )
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - 상품 그리드 셀

struct ProductGridCell: View {
    let product: Product
    let addAction: () -> Void
    
    @Environment(CartStore.self) private var cartStore
    
    private var isInCart: Bool {
        cartStore.contains(product)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 이미지 영역
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.fill.tertiary)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        Image(systemName: product.category.symbol)
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }
                
                // 카테고리 배지
                Text(product.category.rawValue)
                    .font(.caption2.weight(.medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(8)
            }
            
            // 상품 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(2)
                
                Text(product.formattedPrice)
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            
            // 장바구니 버튼
            Button {
                addAction()
            } label: {
                HStack {
                    if isInCart {
                        Image(systemName: "checkmark")
                        Text("담김 (\(cartStore.quantity(of: product)))")
                    } else {
                        Image(systemName: "cart.badge.plus")
                        Text("담기")
                    }
                }
                .font(.subheadline.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    isInCart ? Color.green.opacity(0.1) : Color.accentColor.opacity(0.1),
                    in: RoundedRectangle(cornerRadius: 8)
                )
                .foregroundStyle(isInCart ? .green : .accentColor)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isInCart ? "장바구니에 추가됨, 탭하여 더 추가" : "장바구니에 추가")
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(product.name), \(product.formattedPrice)")
        .accessibilityHint(product.description)
    }
}

// MARK: - 상품 리스트 행

struct ProductListRow: View {
    let product: Product
    let addAction: () -> Void
    
    @Environment(CartStore.self) private var cartStore
    
    private var isInCart: Bool {
        cartStore.contains(product)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 이미지
            RoundedRectangle(cornerRadius: 12)
                .fill(.fill.tertiary)
                .frame(width: 80, height: 80)
                .overlay {
                    Image(systemName: product.category.symbol)
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            
            // 상품 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(product.category.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(product.name)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                
                Text(product.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                Text(product.formattedPrice)
                    .font(.headline)
            }
            
            Spacer()
            
            // 추가 버튼
            Button {
                addAction()
            } label: {
                Image(systemName: isInCart ? "checkmark.circle.fill" : "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(isInCart ? .green : .accentColor)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isInCart ? "장바구니에 추가됨" : "장바구니에 추가")
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(product.name), \(product.formattedPrice)")
    }
}

// MARK: - Preview

#Preview("Grid") {
    NavigationStack {
        ProductListView()
    }
    .environment(CartStore.preview)
}

#Preview("List") {
    NavigationStack {
        ProductListView()
    }
    .environment(CartStore())
}
