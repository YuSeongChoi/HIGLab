import SwiftUI
import MapKit

// MARK: - 메인 콘텐츠 뷰

/// Map과 장소 리스트를 조합한 메인 화면
struct ContentView: View {
    
    // MARK: - Environment
    
    @Environment(LocationManager.self) private var locationManager
    
    // MARK: - State
    
    /// 검색된 장소 목록
    @State private var places: [Place] = []
    
    /// 선택된 장소 (상세보기용)
    @State private var selectedPlace: Place?
    
    /// 현재 선택된 카테고리
    @State private var selectedCategory: PlaceCategory = .restaurant
    
    /// 검색 시트 표시 여부
    @State private var showSearchSheet = false
    
    /// 로딩 상태
    @State private var isLoading = false
    
    /// 에러 메시지
    @State private var errorMessage: String?
    
    /// 지도 카메라 위치
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // 지도 뷰
                MapView(
                    places: places,
                    selectedPlace: $selectedPlace,
                    cameraPosition: $cameraPosition
                )
                .ignoresSafeArea(edges: .top)
                
                // 하단 장소 리스트 시트
                placeListSheet
            }
            .navigationTitle("주변 장소")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    // 현재 위치로 이동 버튼
                    Button {
                        centerOnUserLocation()
                    } label: {
                        Image(systemName: "location.fill")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    // 검색 버튼
                    Button {
                        showSearchSheet = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
            .sheet(isPresented: $showSearchSheet) {
                SearchView(
                    places: $places,
                    selectedPlace: $selectedPlace,
                    cameraPosition: $cameraPosition
                )
                .presentationDetents([.medium, .large])
            }
            .sheet(item: $selectedPlace) { place in
                PlaceDetailView(place: place)
                    .presentationDetents([.medium, .large])
            }
            .task {
                // 초기 위치 권한 요청 및 검색
                locationManager.requestAuthorization()
                await searchNearbyPlaces()
            }
            .onChange(of: selectedCategory) { _, _ in
                Task {
                    await searchNearbyPlaces()
                }
            }
            .onChange(of: locationManager.location) { _, _ in
                Task {
                    await searchNearbyPlaces()
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    /// 하단 장소 리스트 시트
    private var placeListSheet: some View {
        VStack(spacing: 0) {
            // 카테고리 선택 바
            categoryScrollView
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
            
            // 장소 리스트
            if isLoading {
                ProgressView("검색 중...")
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .background(.regularMaterial)
            } else if let error = errorMessage {
                errorView(message: error)
            } else if places.isEmpty {
                emptyStateView
            } else {
                placeListView
            }
        }
    }
    
    /// 카테고리 가로 스크롤
    private var categoryScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(PlaceCategory.allCases) { category in
                    CategoryChip(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    /// 장소 가로 스크롤 리스트
    private var placeListView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(places) { place in
                    PlaceCard(place: place) {
                        selectedPlace = place
                        // 선택한 장소로 카메라 이동
                        withAnimation {
                            cameraPosition = .camera(
                                MapCamera(
                                    centerCoordinate: place.coordinate,
                                    distance: 1000
                                )
                            )
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
        }
        .frame(height: 180)
        .background(.regularMaterial)
    }
    
    /// 빈 상태 뷰
    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "map")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("주변에 \(selectedCategory.rawValue)이(가) 없습니다")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
    }
    
    /// 에러 뷰
    private func errorView(message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button("다시 시도") {
                Task {
                    await searchNearbyPlaces()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(height: 180)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
    }
    
    // MARK: - Methods
    
    /// 현재 위치 주변 장소 검색
    private func searchNearbyPlaces() async {
        isLoading = true
        errorMessage = nil
        
        do {
            places = try await PlaceService.shared.searchPlaces(
                category: selectedCategory,
                near: locationManager.coordinate
            )
        } catch {
            errorMessage = "검색 중 오류가 발생했습니다: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// 사용자 현재 위치로 카메라 이동
    private func centerOnUserLocation() {
        locationManager.requestLocation()
        
        withAnimation {
            cameraPosition = .camera(
                MapCamera(
                    centerCoordinate: locationManager.coordinate,
                    distance: 2000
                )
            )
        }
    }
}

// MARK: - 카테고리 칩

struct CategoryChip: View {
    let category: PlaceCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.symbol)
                    .font(.caption)
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color(.systemGray5))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 장소 카드

struct PlaceCard: View {
    let place: Place
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                // 카테고리 아이콘
                HStack {
                    Image(systemName: place.category.symbol)
                        .font(.title2)
                        .foregroundStyle(Color(place.category.color))
                    
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
                }
                
                // 장소명
                Text(place.name)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // 주소
                if let address = place.address {
                    Text(address)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // 카테고리 태그
                Text(place.category.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(place.category.color).opacity(0.15))
                    .foregroundStyle(Color(place.category.color))
                    .clipShape(Capsule())
            }
            .padding()
            .frame(width: 160, height: 140)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environment(LocationManager())
}
