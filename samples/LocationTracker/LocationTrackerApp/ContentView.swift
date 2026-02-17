import SwiftUI
import CoreLocation

// MARK: - 메인 콘텐츠 뷰
// 현재 위치 정보와 탭 네비게이션을 표시하는 메인 화면

struct ContentView: View {
    
    // MARK: - Environment
    
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var geofenceManager: GeofenceManager
    
    // MARK: - State
    
    /// 현재 선택된 탭
    @State private var selectedTab = 0
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 현재 위치 탭
            CurrentLocationView()
                .tabItem {
                    Label("현재 위치", systemImage: "location.fill")
                }
                .tag(0)
            
            // 경로 지도 탭
            MapTrackView()
                .tabItem {
                    Label("경로", systemImage: "map.fill")
                }
                .tag(1)
            
            // 지오펜스 탭
            GeofenceSetupView()
                .tabItem {
                    Label("지오펜스", systemImage: "mappin.circle.fill")
                }
                .tag(2)
            
            // 기록 탭
            HistoryView()
                .tabItem {
                    Label("기록", systemImage: "clock.fill")
                }
                .tag(3)
            
            // 설정 탭
            SettingsView()
                .tabItem {
                    Label("설정", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .onAppear {
            // 앱 시작 시 권한 확인
            checkLocationPermission()
        }
    }
    
    // MARK: - Methods
    
    /// 위치 권한 확인 및 요청
    private func checkLocationPermission() {
        switch locationManager.permissionStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
}

// MARK: - 현재 위치 뷰

/// 현재 위치 정보를 표시하는 화면
struct CurrentLocationView: View {
    
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 권한 상태 카드
                    permissionCard
                    
                    // 현재 위치 카드
                    if locationManager.permissionStatus.isAuthorized {
                        locationCard
                        
                        // 추적 상태 카드
                        trackingCard
                        
                        // 상세 정보
                        if let point = locationManager.currentPoint {
                            detailCard(point)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("현재 위치")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        locationManager.requestLocation()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(!locationManager.permissionStatus.isAuthorized)
                }
            }
            .alert("오류", isPresented: .constant(locationManager.errorMessage != nil)) {
                Button("확인") {
                    locationManager.clearError()
                }
            } message: {
                Text(locationManager.errorMessage ?? "")
            }
        }
    }
    
    // MARK: - 권한 상태 카드
    
    private var permissionCard: some View {
        CardView {
            HStack {
                Image(systemName: permissionIcon)
                    .font(.title2)
                    .foregroundColor(permissionColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("위치 권한")
                        .font(.headline)
                    Text(locationManager.permissionStatus.displayText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !locationManager.permissionStatus.isAuthorized &&
                   locationManager.permissionStatus != .notDetermined {
                    Button("설정") {
                        locationManager.openSettings()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
    
    private var permissionIcon: String {
        switch locationManager.permissionStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return "checkmark.circle.fill"
        case .denied, .restricted:
            return "xmark.circle.fill"
        case .notDetermined:
            return "questionmark.circle.fill"
        }
    }
    
    private var permissionColor: Color {
        switch locationManager.permissionStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return .green
        case .denied, .restricted:
            return .red
        case .notDetermined:
            return .orange
        }
    }
    
    // MARK: - 현재 위치 카드
    
    private var locationCard: some View {
        CardView {
            VStack(spacing: 16) {
                // 위치 아이콘
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                
                if let point = locationManager.currentPoint {
                    // 좌표 표시
                    VStack(spacing: 8) {
                        Text(String(format: "%.6f, %.6f", point.latitude, point.longitude))
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("정확도: ±\(Int(point.horizontalAccuracy))m")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("위치 확인 중...")
                        .foregroundColor(.secondary)
                    
                    ProgressView()
                        .padding(.top, 8)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - 추적 상태 카드
    
    private var trackingCard: some View {
        CardView {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("경로 기록")
                            .font(.headline)
                        
                        if locationManager.isTracking,
                           let track = locationManager.activeTrack {
                            Text("\(track.points.count)개 포인트")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        } else {
                            Text("추적 중지됨")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // 추적 상태 인디케이터
                    if locationManager.isTracking {
                        Circle()
                            .fill(.red)
                            .frame(width: 12, height: 12)
                            .overlay {
                                Circle()
                                    .stroke(.red.opacity(0.5), lineWidth: 4)
                            }
                    }
                }
                
                // 추적 버튼
                HStack(spacing: 12) {
                    if locationManager.isTracking || locationManager.activeTrack != nil {
                        // 일시정지/재개 버튼
                        Button {
                            locationManager.togglePauseTracking()
                        } label: {
                            Label(
                                locationManager.isTracking ? "일시정지" : "재개",
                                systemImage: locationManager.isTracking ? "pause.fill" : "play.fill"
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        
                        // 중지 버튼
                        Button {
                            locationManager.stopTracking()
                        } label: {
                            Label("중지", systemImage: "stop.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    } else {
                        // 시작 버튼
                        Button {
                            locationManager.startTracking()
                        } label: {
                            Label("기록 시작", systemImage: "record.circle")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
    }
    
    // MARK: - 상세 정보 카드
    
    private func detailCard(_ point: LocationPoint) -> some View {
        CardView {
            VStack(spacing: 12) {
                Text("상세 정보")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                // 고도
                DetailRow(
                    icon: "arrow.up.forward",
                    title: "고도",
                    value: String(format: "%.1f m", point.altitude)
                )
                
                // 속도
                DetailRow(
                    icon: "speedometer",
                    title: "속도",
                    value: point.speed >= 0 ?
                        String(format: "%.1f km/h", point.speedKmh) : "측정 불가"
                )
                
                // 방향
                DetailRow(
                    icon: "safari",
                    title: "방향",
                    value: point.courseDirection
                )
                
                // 시간
                DetailRow(
                    icon: "clock",
                    title: "업데이트",
                    value: point.timestamp.formatted(date: .omitted, time: .standard)
                )
            }
        }
    }
}

// MARK: - 상세 정보 행

/// 상세 정보 표시용 행 컴포넌트
struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(.blue)
            
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
    }
}

// MARK: - 카드 뷰

/// 재사용 가능한 카드 컨테이너
struct CardView<Content: View>: View {
    @ViewBuilder let content: Content
    
    var body: some View {
        content
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.background)
                    .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
            }
    }
}

// MARK: - 미리보기

#Preview {
    ContentView()
        .environmentObject(LocationManager.shared)
        .environmentObject(GeofenceManager.shared)
}
