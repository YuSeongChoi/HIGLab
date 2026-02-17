import SwiftUI
import MapKit

// MARK: - 검색 뷰

/// 장소 키워드 검색 UI
struct SearchView: View {
    
    // MARK: - Bindings
    
    /// 검색 결과 (부모 뷰에 전달)
    @Binding var places: [Place]
    
    /// 선택된 장소
    @Binding var selectedPlace: Place?
    
    /// 카메라 위치
    @Binding var cameraPosition: MapCameraPosition
    
    // MARK: - Environment
    
    @Environment(\.dismiss) private var dismiss
    @Environment(LocationManager.self) private var locationManager
    
    // MARK: - State
    
    /// 검색어
    @State private var searchText = ""
    
    /// 검색 결과
    @State private var searchResults: [Place] = []
    
    /// 최근 검색어
    @State private var recentSearches: [String] = [
        "맛집", "카페", "주차장", "편의점"
    ]
    
    /// 로딩 상태
    @State private var isSearching = false
    
    /// 에러 메시지
    @State private var errorMessage: String?
    
    /// 검색 디바운스 태스크
    @State private var searchTask: Task<Void, Never>?
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 검색 바
                searchBar
                
                // 검색 결과 또는 추천
                if searchText.isEmpty {
                    recentSearchesView
                } else {
                    searchResultsView
                }
            }
            .navigationTitle("장소 검색")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    /// 검색 바
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField("장소, 주소 검색", text: $searchText)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onSubmit {
                    performSearch()
                }
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    searchResults = []
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding()
        .onChange(of: searchText) { _, newValue in
            // 디바운스 검색 (타이핑 중 0.5초 대기)
            searchTask?.cancel()
            
            guard !newValue.isEmpty else {
                searchResults = []
                return
            }
            
            searchTask = Task {
                try? await Task.sleep(for: .milliseconds(500))
                
                guard !Task.isCancelled else { return }
                await performSearchAsync()
            }
        }
    }
    
    /// 최근 검색어 뷰
    private var recentSearchesView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 헤더
            HStack {
                Text("최근 검색")
                    .font(.headline)
                Spacer()
                Button("모두 지우기") {
                    recentSearches = []
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            
            // 최근 검색어 목록
            if recentSearches.isEmpty {
                emptyRecentView
            } else {
                recentSearchList
            }
            
            Divider()
                .padding(.vertical, 8)
            
            // 추천 카테고리
            Text("추천 카테고리")
                .font(.headline)
                .padding(.horizontal)
            
            categoryGrid
            
            Spacer()
        }
        .padding(.top)
    }
    
    /// 최근 검색어 목록
    private var recentSearchList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(recentSearches, id: \.self) { query in
                    Button {
                        searchText = query
                        performSearch()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.caption)
                            Text(query)
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
    
    /// 빈 최근 검색어 뷰
    private var emptyRecentView: some View {
        Text("최근 검색 기록이 없습니다")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding()
    }
    
    /// 카테고리 그리드
    private var categoryGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            ForEach(PlaceCategory.allCases) { category in
                Button {
                    searchText = category.rawValue
                    performSearch()
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: category.symbol)
                            .font(.title2)
                            .foregroundStyle(Color(category.color))
                        Text(category.rawValue)
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
    
    /// 검색 결과 뷰
    private var searchResultsView: some View {
        VStack {
            if isSearching {
                Spacer()
                ProgressView("검색 중...")
                Spacer()
            } else if let error = errorMessage {
                Spacer()
                errorView(message: error)
                Spacer()
            } else if searchResults.isEmpty && !searchText.isEmpty {
                Spacer()
                noResultsView
                Spacer()
            } else {
                searchResultsList
            }
        }
    }
    
    /// 검색 결과 목록
    private var searchResultsList: some View {
        List(searchResults) { place in
            Button {
                selectPlace(place)
            } label: {
                SearchResultRow(place: place)
            }
            .buttonStyle(.plain)
        }
        .listStyle(.plain)
    }
    
    /// 검색 결과 없음 뷰
    private var noResultsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("'\(searchText)'에 대한 검색 결과가 없습니다")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    /// 에러 뷰
    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button("다시 시도") {
                performSearch()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    // MARK: - Methods
    
    /// 검색 실행 (버튼/엔터)
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        // 최근 검색어에 추가
        if !recentSearches.contains(searchText) {
            recentSearches.insert(searchText, at: 0)
            if recentSearches.count > 10 {
                recentSearches.removeLast()
            }
        }
        
        Task {
            await performSearchAsync()
        }
    }
    
    /// 비동기 검색
    @MainActor
    private func performSearchAsync() async {
        isSearching = true
        errorMessage = nil
        
        do {
            searchResults = try await PlaceService.shared.searchPlaces(
                query: searchText,
                near: locationManager.coordinate
            )
        } catch {
            errorMessage = "검색 중 오류가 발생했습니다"
        }
        
        isSearching = false
    }
    
    /// 장소 선택
    private func selectPlace(_ place: Place) {
        // 검색 결과를 메인 뷰에 반영
        places = searchResults
        selectedPlace = place
        
        // 선택한 장소로 카메라 이동
        cameraPosition = .camera(
            MapCamera(
                centerCoordinate: place.coordinate,
                distance: 1000
            )
        )
        
        dismiss()
    }
}

// MARK: - 검색 결과 행

struct SearchResultRow: View {
    let place: Place
    
    var body: some View {
        HStack(spacing: 12) {
            // 카테고리 아이콘
            Image(systemName: place.category.symbol)
                .font(.title3)
                .foregroundStyle(Color(place.category.color))
                .frame(width: 40, height: 40)
                .background(Color(place.category.color).opacity(0.15))
                .clipShape(Circle())
            
            // 장소 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(place.name)
                    .font(.body)
                    .fontWeight(.medium)
                
                if let address = place.address {
                    Text(address)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // 평점
            if let rating = place.rating {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                    Text(String(format: "%.1f", rating))
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    SearchView(
        places: .constant([]),
        selectedPlace: .constant(nil),
        cameraPosition: .constant(.automatic)
    )
    .environment(LocationManager())
}
