import SwiftUI
import MapKit

// MARK: - 경로 지도 뷰
// 현재 위치와 기록된 경로를 지도에 표시하는 화면

struct MapTrackView: View {
    
    // MARK: - Environment
    
    @EnvironmentObject var locationManager: LocationManager
    
    // MARK: - State
    
    /// 지도 카메라 위치
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    /// 선택된 경로
    @State private var selectedTrack: LocationTrack?
    
    /// 경로 목록 시트 표시 여부
    @State private var showTrackList = false
    
    /// 지도 스타일
    @State private var mapStyle: MapStyle = .standard
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // 지도
                mapContent
                
                // 하단 정보 패널
                if let track = displayTrack {
                    trackInfoPanel(track)
                }
            }
            .navigationTitle("경로 지도")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 지도 스타일 변경
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button {
                            mapStyle = .standard
                        } label: {
                            Label("기본", systemImage: mapStyle == .standard ? "checkmark" : "")
                        }
                        
                        Button {
                            mapStyle = .imagery
                        } label: {
                            Label("위성", systemImage: mapStyle == .imagery ? "checkmark" : "")
                        }
                        
                        Button {
                            mapStyle = .hybrid
                        } label: {
                            Label("하이브리드", systemImage: mapStyle == .hybrid ? "checkmark" : "")
                        }
                    } label: {
                        Image(systemName: "map")
                    }
                }
                
                // 경로 목록
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showTrackList = true
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                }
                
                // 현재 위치로 이동
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        centerOnCurrentLocation()
                    } label: {
                        Image(systemName: "location")
                    }
                }
            }
            .sheet(isPresented: $showTrackList) {
                trackListSheet
            }
        }
    }
    
    // MARK: - 지도 콘텐츠
    
    private var mapContent: some View {
        Map(position: $cameraPosition) {
            // 현재 위치 마커
            if let location = locationManager.currentLocation {
                Annotation("현재 위치", coordinate: location.coordinate) {
                    CurrentLocationMarker()
                }
            }
            
            // 활성 경로 표시 (기록 중)
            if let activeTrack = locationManager.activeTrack,
               activeTrack.points.count > 1 {
                // 경로 라인
                MapPolyline(coordinates: activeTrack.points.map(\.coordinate))
                    .stroke(.red, lineWidth: 4)
                
                // 시작점 마커
                if let start = activeTrack.points.first {
                    Annotation("시작", coordinate: start.coordinate) {
                        TrackPointMarker(type: .start)
                    }
                }
            }
            
            // 선택된 저장 경로 표시
            if let track = selectedTrack, track.points.count > 1 {
                // 경로 라인
                MapPolyline(coordinates: track.points.map(\.coordinate))
                    .stroke(.blue, lineWidth: 4)
                
                // 시작점 마커
                if let start = track.points.first {
                    Annotation("시작", coordinate: start.coordinate) {
                        TrackPointMarker(type: .start)
                    }
                }
                
                // 종료점 마커
                if let end = track.points.last {
                    Annotation("종료", coordinate: end.coordinate) {
                        TrackPointMarker(type: .end)
                    }
                }
            }
        }
        .mapStyle(mapStyle == .standard ? .standard :
                  mapStyle == .imagery ? .imagery : .hybrid)
        .mapControls {
            MapCompass()
            MapScaleView()
        }
    }
    
    // MARK: - 표시할 경로
    
    /// 현재 표시 중인 경로 (활성 또는 선택된 경로)
    private var displayTrack: LocationTrack? {
        locationManager.activeTrack ?? selectedTrack
    }
    
    // MARK: - 경로 정보 패널
    
    private func trackInfoPanel(_ track: LocationTrack) -> some View {
        VStack(spacing: 12) {
            // 경로 이름
            HStack {
                Text(track.name)
                    .font(.headline)
                
                Spacer()
                
                if track.isActive {
                    // 기록 중 표시
                    HStack(spacing: 4) {
                        Circle()
                            .fill(.red)
                            .frame(width: 8, height: 8)
                        Text("기록 중")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            
            Divider()
            
            // 통계 정보
            HStack(spacing: 20) {
                StatItem(
                    icon: "point.topleft.down.curvedto.point.bottomright.up",
                    title: "거리",
                    value: String(format: "%.2f km", track.totalDistanceKm)
                )
                
                StatItem(
                    icon: "clock",
                    title: "시간",
                    value: track.formattedDuration
                )
                
                StatItem(
                    icon: "speedometer",
                    title: "평균 속도",
                    value: String(format: "%.1f km/h", track.averageSpeed)
                )
                
                StatItem(
                    icon: "mappin.circle",
                    title: "포인트",
                    value: "\(track.points.count)"
                )
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
        }
        .padding()
    }
    
    // MARK: - 경로 목록 시트
    
    private var trackListSheet: some View {
        NavigationStack {
            List {
                // 현재 기록 중인 경로
                if let activeTrack = locationManager.activeTrack {
                    Section("기록 중") {
                        TrackRow(track: activeTrack, isActive: true)
                            .onTapGesture {
                                selectedTrack = nil
                                showTrackList = false
                                fitMapToTrack(activeTrack)
                            }
                    }
                }
                
                // 저장된 경로
                Section("저장된 경로") {
                    if locationManager.savedTracks.isEmpty {
                        Text("저장된 경로가 없습니다")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(locationManager.savedTracks) { track in
                            TrackRow(track: track, isActive: false)
                                .onTapGesture {
                                    selectedTrack = track
                                    showTrackList = false
                                    fitMapToTrack(track)
                                }
                        }
                    }
                }
            }
            .navigationTitle("경로 목록")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        showTrackList = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    // MARK: - Methods
    
    /// 현재 위치로 지도 이동
    private func centerOnCurrentLocation() {
        guard let location = locationManager.currentLocation else { return }
        
        cameraPosition = .region(MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    /// 경로에 맞게 지도 영역 조정
    private func fitMapToTrack(_ track: LocationTrack) {
        guard !track.points.isEmpty else { return }
        
        let coordinates = track.points.map(\.coordinate)
        
        // 경계 계산
        let minLat = coordinates.map(\.latitude).min() ?? 0
        let maxLat = coordinates.map(\.latitude).max() ?? 0
        let minLon = coordinates.map(\.longitude).min() ?? 0
        let maxLon = coordinates.map(\.longitude).max() ?? 0
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.3 + 0.005,
            longitudeDelta: (maxLon - minLon) * 1.3 + 0.005
        )
        
        cameraPosition = .region(MKCoordinateRegion(center: center, span: span))
    }
}

// MARK: - 지도 스타일 열거형

enum MapStyle: String, CaseIterable {
    case standard = "기본"
    case imagery = "위성"
    case hybrid = "하이브리드"
}

// MARK: - 현재 위치 마커

/// 현재 위치를 표시하는 파란색 점 마커
struct CurrentLocationMarker: View {
    var body: some View {
        ZStack {
            // 외부 원 (펄싱 효과용)
            Circle()
                .fill(.blue.opacity(0.2))
                .frame(width: 40, height: 40)
            
            // 내부 원
            Circle()
                .fill(.blue)
                .frame(width: 16, height: 16)
            
            // 테두리
            Circle()
                .stroke(.white, lineWidth: 3)
                .frame(width: 16, height: 16)
        }
    }
}

// MARK: - 경로 포인트 마커

/// 경로의 시작/종료점을 표시하는 마커
struct TrackPointMarker: View {
    enum PointType {
        case start, end
    }
    
    let type: PointType
    
    var body: some View {
        ZStack {
            Circle()
                .fill(type == .start ? .green : .red)
                .frame(width: 24, height: 24)
            
            Image(systemName: type == .start ? "play.fill" : "stop.fill")
                .font(.caption2)
                .foregroundColor(.white)
        }
        .shadow(radius: 2)
    }
}

// MARK: - 통계 아이템

/// 통계 정보 표시 컴포넌트
struct StatItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 경로 행

/// 경로 목록 행 컴포넌트
struct TrackRow: View {
    let track: LocationTrack
    let isActive: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(track.name)
                        .font(.headline)
                    
                    if isActive {
                        Circle()
                            .fill(.red)
                            .frame(width: 8, height: 8)
                    }
                }
                
                Text("\(track.points.count)개 포인트 • \(track.formattedDuration)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.2f km", track.totalDistanceKm))
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(track.startTime.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .contentShape(Rectangle())
    }
}

// MARK: - 미리보기

#Preview {
    MapTrackView()
        .environmentObject(LocationManager.shared)
}
