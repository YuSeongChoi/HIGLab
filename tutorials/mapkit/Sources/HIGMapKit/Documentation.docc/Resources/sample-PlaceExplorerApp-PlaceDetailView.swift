import SwiftUI
import MapKit

// MARK: - 장소 상세 뷰

/// Look Around 프리뷰와 길찾기 기능을 포함한 장소 상세 화면
struct PlaceDetailView: View {
    
    // MARK: - Properties
    
    let place: Place
    
    // MARK: - Environment
    
    @Environment(\.dismiss) private var dismiss
    @Environment(LocationManager.self) private var locationManager
    
    // MARK: - State
    
    /// Look Around 장면
    @State private var lookAroundScene: MKLookAroundScene?
    
    /// Look Around 로딩 중
    @State private var isLoadingLookAround = false
    
    /// 경로 정보
    @State private var route: MKRoute?
    
    /// 경로 로딩 중
    @State private var isLoadingRoute = false
    
    /// 선택된 이동 수단
    @State private var transportType: MKDirectionsTransportType = .walking
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 헤더 (Look Around 또는 지도)
                    headerView
                    
                    // 장소 정보
                    placeInfoSection
                    
                    // 길찾기 섹션
                    directionsSection
                    
                    // 액션 버튼들
                    actionButtons
                }
                .padding(.bottom, 32)
            }
            .navigationTitle(place.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
            .task {
                await loadLookAroundScene()
                await loadRoute()
            }
        }
    }
    
    // MARK: - Subviews
    
    /// 헤더 뷰 (Look Around 또는 미니 지도)
    @ViewBuilder
    private var headerView: some View {
        if isLoadingLookAround {
            // 로딩 상태
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray5))
                .frame(height: 220)
                .overlay {
                    ProgressView()
                }
                .padding(.horizontal)
        } else if let scene = lookAroundScene {
            // Look Around 프리뷰 (iOS 17+)
            LookAroundPreview(scene: .constant(scene))
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
        } else {
            // Look Around 없으면 미니 지도 표시
            miniMapView
        }
    }
    
    /// 미니 지도 (Look Around 불가 시 대체)
    private var miniMapView: some View {
        Map {
            Marker(place.name, coordinate: place.coordinate)
                .tint(Color(place.category.color))
        }
        .mapStyle(.imagery(elevation: .realistic))
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .disabled(true)
        .padding(.horizontal)
    }
    
    /// 장소 정보 섹션
    private var placeInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 카테고리 & 평점
            HStack {
                // 카테고리 태그
                Label(place.category.rawValue, systemImage: place.category.symbol)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(place.category.color).opacity(0.15))
                    .foregroundStyle(Color(place.category.color))
                    .clipShape(Capsule())
                
                Spacer()
                
                // 평점
                if let rating = place.rating {
                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(rating) ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundStyle(.yellow)
                        }
                        Text(String(format: "%.1f", rating))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }
            
            Divider()
            
            // 주소
            if let address = place.address {
                Label {
                    Text(address)
                        .font(.subheadline)
                } icon: {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(.red)
                }
            }
            
            // 전화번호
            if let phone = place.phoneNumber {
                Label {
                    Button(phone) {
                        // 전화 걸기
                        if let url = URL(string: "tel://\(phone.replacingOccurrences(of: "-", with: ""))") {
                            UIApplication.shared.open(url)
                        }
                    }
                    .font(.subheadline)
                } icon: {
                    Image(systemName: "phone.circle.fill")
                        .foregroundStyle(.green)
                }
            }
            
            // 좌표
            Label {
                Text(String(format: "%.4f, %.4f", place.coordinate.latitude, place.coordinate.longitude))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } icon: {
                Image(systemName: "location.circle.fill")
                    .foregroundStyle(.blue)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
    
    /// 길찾기 섹션
    private var directionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("길찾기")
                .font(.headline)
            
            // 이동 수단 선택
            Picker("이동 수단", selection: $transportType) {
                Label("도보", systemImage: "figure.walk")
                    .tag(MKDirectionsTransportType.walking)
                Label("자동차", systemImage: "car.fill")
                    .tag(MKDirectionsTransportType.automobile)
                Label("대중교통", systemImage: "bus.fill")
                    .tag(MKDirectionsTransportType.transit)
            }
            .pickerStyle(.segmented)
            .onChange(of: transportType) { _, _ in
                Task {
                    await loadRoute()
                }
            }
            
            // 경로 정보
            if isLoadingRoute {
                HStack {
                    ProgressView()
                    Text("경로 계산 중...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else if let route = route {
                routeInfoView(route: route)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
    
    /// 경로 정보 뷰
    private func routeInfoView(route: MKRoute) -> some View {
        HStack(spacing: 24) {
            // 거리
            VStack {
                Image(systemName: "arrow.triangle.swap")
                    .font(.title2)
                    .foregroundStyle(.blue)
                Text(formatDistance(route.distance))
                    .font(.headline)
                Text("거리")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
                .frame(height: 50)
            
            // 소요 시간
            VStack {
                Image(systemName: "clock.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                Text(formatDuration(route.expectedTravelTime))
                    .font(.headline)
                Text("예상 시간")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
                .frame(height: 50)
            
            // 경로명
            VStack {
                Image(systemName: "road.lanes")
                    .font(.title2)
                    .foregroundStyle(.green)
                Text(route.name)
                    .font(.headline)
                    .lineLimit(1)
                Text("경로")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
    
    /// 액션 버튼들
    private var actionButtons: some View {
        HStack(spacing: 16) {
            // Apple Maps에서 열기
            Button {
                openInMaps()
            } label: {
                Label("지도에서 열기", systemImage: "map.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            
            // 공유
            ShareLink(
                item: "📍 \(place.name)\n\(place.address ?? "")",
                subject: Text(place.name),
                message: Text("이 장소를 확인해보세요!")
            ) {
                Label("공유", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Methods
    
    /// Look Around 장면 로드
    private func loadLookAroundScene() async {
        isLoadingLookAround = true
        
        let request = MKLookAroundSceneRequest(coordinate: place.coordinate)
        
        do {
            lookAroundScene = try await request.scene
        } catch {
            // Look Around 불가 지역일 수 있음
            print("Look Around 로드 실패: \(error)")
        }
        
        isLoadingLookAround = false
    }
    
    /// 경로 로드
    private func loadRoute() async {
        isLoadingRoute = true
        route = nil
        
        do {
            route = try await PlaceService.shared.calculateRoute(
                to: place.coordinate,
                from: locationManager.coordinate,
                transportType: transportType
            )
        } catch {
            print("경로 계산 실패: \(error)")
        }
        
        isLoadingRoute = false
    }
    
    /// Apple Maps 앱에서 열기
    private func openInMaps() {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: place.coordinate))
        mapItem.name = place.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: directionsMode
        ])
    }
    
    /// 이동 수단에 따른 directions mode
    private var directionsMode: String {
        switch transportType {
        case .walking:
            return MKLaunchOptionsDirectionsModeWalking
        case .automobile:
            return MKLaunchOptionsDirectionsModeDriving
        case .transit:
            return MKLaunchOptionsDirectionsModeTransit
        default:
            return MKLaunchOptionsDirectionsModeDefault
        }
    }
    
    /// 거리 포맷팅
    private func formatDistance(_ meters: CLLocationDistance) -> String {
        if meters < 1000 {
            return "\(Int(meters))m"
        } else {
            return String(format: "%.1fkm", meters / 1000)
        }
    }
    
    /// 시간 포맷팅
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds / 60)
        if minutes < 60 {
            return "\(minutes)분"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours)시간 \(remainingMinutes)분"
        }
    }
}

// MARK: - Preview

#Preview {
    PlaceDetailView(place: Place.preview)
        .environment(LocationManager())
}
