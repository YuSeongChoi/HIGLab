import SwiftUI
import MapKit

// MARK: - 기록 뷰
// 저장된 경로 기록을 관리하고 상세 정보를 표시하는 화면

struct HistoryView: View {
    
    // MARK: - Environment
    
    @EnvironmentObject var locationManager: LocationManager
    
    // MARK: - State
    
    /// 선택된 경로 (상세 보기용)
    @State private var selectedTrack: LocationTrack?
    
    /// 삭제 확인 알림 표시
    @State private var showDeleteConfirmation = false
    
    /// 삭제할 경로
    @State private var trackToDelete: LocationTrack?
    
    /// 전체 삭제 확인 표시
    @State private var showDeleteAllConfirmation = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Group {
                if locationManager.savedTracks.isEmpty {
                    // 빈 상태
                    emptyState
                } else {
                    // 경로 목록
                    trackList
                }
            }
            .navigationTitle("기록")
            .toolbar {
                if !locationManager.savedTracks.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button(role: .destructive) {
                                showDeleteAllConfirmation = true
                            } label: {
                                Label("모두 삭제", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .sheet(item: $selectedTrack) { track in
                TrackDetailView(track: track)
            }
            .alert("경로 삭제", isPresented: $showDeleteConfirmation) {
                Button("취소", role: .cancel) {}
                Button("삭제", role: .destructive) {
                    if let track = trackToDelete {
                        locationManager.deleteTrack(track)
                    }
                }
            } message: {
                Text("이 경로를 삭제하시겠습니까?")
            }
            .alert("모든 기록 삭제", isPresented: $showDeleteAllConfirmation) {
                Button("취소", role: .cancel) {}
                Button("모두 삭제", role: .destructive) {
                    locationManager.deleteAllTracks()
                }
            } message: {
                Text("저장된 모든 경로가 삭제됩니다. 이 작업은 되돌릴 수 없습니다.")
            }
        }
    }
    
    // MARK: - 빈 상태
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("저장된 기록이 없습니다")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("'현재 위치' 탭에서 경로 기록을 시작해보세요.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    // MARK: - 경로 목록
    
    private var trackList: some View {
        List {
            // 통계 섹션
            Section {
                StatisticsCard(tracks: locationManager.savedTracks)
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            
            // 경로 목록 섹션
            Section("저장된 경로") {
                ForEach(locationManager.savedTracks) { track in
                    HistoryTrackRow(track: track)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedTrack = track
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                trackToDelete = track
                                showDeleteConfirmation = true
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                }
            }
        }
    }
}

// MARK: - 통계 카드

/// 전체 통계를 표시하는 카드
struct StatisticsCard: View {
    let tracks: [LocationTrack]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("전체 통계")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                StatBox(
                    icon: "figure.walk",
                    title: "총 경로",
                    value: "\(tracks.count)개"
                )
                
                StatBox(
                    icon: "point.topleft.down.curvedto.point.bottomright.up",
                    title: "총 거리",
                    value: String(format: "%.1f km", totalDistance)
                )
                
                StatBox(
                    icon: "clock",
                    title: "총 시간",
                    value: formattedTotalDuration
                )
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.blue.opacity(0.1))
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    /// 총 이동 거리 (km)
    private var totalDistance: Double {
        tracks.reduce(0) { $0 + $1.totalDistanceKm }
    }
    
    /// 총 소요 시간
    private var totalDuration: TimeInterval {
        tracks.reduce(0) { $0 + $1.duration }
    }
    
    /// 총 소요 시간 포맷팅
    private var formattedTotalDuration: String {
        let hours = Int(totalDuration) / 3600
        let minutes = (Int(totalDuration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)시간 \(minutes)분"
        } else {
            return "\(minutes)분"
        }
    }
}

// MARK: - 통계 박스

/// 개별 통계 항목 컴포넌트
struct StatBox: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 기록 경로 행

/// 기록 목록의 경로 행 컴포넌트
struct HistoryTrackRow: View {
    let track: LocationTrack
    
    var body: some View {
        HStack(spacing: 12) {
            // 미니 지도 미리보기
            miniMapPreview
            
            // 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(track.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(track.startTime.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    Label(String(format: "%.2f km", track.totalDistanceKm), systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                    Label(track.formattedDuration, systemImage: "clock")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    /// 미니 지도 미리보기
    private var miniMapPreview: some View {
        Group {
            if track.points.count > 1 {
                // 경로가 있으면 미니맵 표시
                MiniMapView(coordinates: track.points.map(\.coordinate))
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                // 경로가 없으면 아이콘 표시
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: "map")
                            .foregroundColor(.gray)
                    }
            }
        }
    }
}

// MARK: - 미니 지도 뷰

/// 경로를 표시하는 미니 지도
struct MiniMapView: View {
    let coordinates: [CLLocationCoordinate2D]
    
    var body: some View {
        Map(interactionModes: []) {
            MapPolyline(coordinates: coordinates)
                .stroke(.blue, lineWidth: 2)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - 경로 상세 뷰

/// 경로 상세 정보를 표시하는 시트
struct TrackDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var locationManager: LocationManager
    
    let track: LocationTrack
    
    // MARK: - State
    
    @State private var isEditing = false
    @State private var editedName: String = ""
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 지도
                    mapSection
                    
                    // 통계
                    statisticsSection
                    
                    // 포인트 목록
                    pointsSection
                }
                .padding()
            }
            .navigationTitle(track.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("이름 변경") {
                        editedName = track.name
                        isEditing = true
                    }
                }
            }
            .alert("경로 이름 변경", isPresented: $isEditing) {
                TextField("경로 이름", text: $editedName)
                Button("취소", role: .cancel) {}
                Button("저장") {
                    locationManager.renameTrack(track, to: editedName)
                }
            }
            .onAppear {
                fitMapToTrack()
            }
        }
    }
    
    // MARK: - 지도 섹션
    
    private var mapSection: some View {
        Map(position: $cameraPosition) {
            if track.points.count > 1 {
                MapPolyline(coordinates: track.points.map(\.coordinate))
                    .stroke(.blue, lineWidth: 4)
                
                if let start = track.points.first {
                    Annotation("시작", coordinate: start.coordinate) {
                        TrackPointMarker(type: .start)
                    }
                }
                
                if let end = track.points.last {
                    Annotation("종료", coordinate: end.coordinate) {
                        TrackPointMarker(type: .end)
                    }
                }
            }
        }
        .frame(height: 250)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - 통계 섹션
    
    private var statisticsSection: some View {
        VStack(spacing: 12) {
            Text("통계")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(title: "총 거리", value: String(format: "%.2f km", track.totalDistanceKm), icon: "point.topleft.down.curvedto.point.bottomright.up")
                StatCard(title: "소요 시간", value: track.formattedDuration, icon: "clock")
                StatCard(title: "평균 속도", value: String(format: "%.1f km/h", track.averageSpeed), icon: "speedometer")
                StatCard(title: "최고 속도", value: String(format: "%.1f km/h", track.maxSpeed), icon: "gauge.with.dots.needle.67percent")
                StatCard(title: "포인트 수", value: "\(track.points.count)개", icon: "mappin")
                StatCard(title: "시작 시간", value: track.startTime.formatted(date: .omitted, time: .shortened), icon: "play.circle")
            }
        }
    }
    
    // MARK: - 포인트 섹션
    
    private var pointsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("경로 포인트")
                    .font(.headline)
                
                Spacer()
                
                Text("\(track.points.count)개")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // 처음 10개만 표시
            ForEach(Array(track.points.prefix(10).enumerated()), id: \.element.id) { index, point in
                PointRow(index: index + 1, point: point)
            }
            
            if track.points.count > 10 {
                Text("... 외 \(track.points.count - 10)개 포인트")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Methods
    
    private func fitMapToTrack() {
        guard !track.points.isEmpty else { return }
        
        let coordinates = track.points.map(\.coordinate)
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

// MARK: - 통계 카드

/// 통계 항목 카드
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(.gray.opacity(0.1))
        }
    }
}

// MARK: - 포인트 행

/// 포인트 목록 행
struct PointRow: View {
    let index: Int
    let point: LocationPoint
    
    var body: some View {
        HStack(spacing: 12) {
            // 인덱스
            Text("\(index)")
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 28, height: 28)
                .background(Circle().fill(.blue.opacity(0.2)))
            
            // 좌표
            VStack(alignment: .leading, spacing: 2) {
                Text(String(format: "%.6f, %.6f", point.latitude, point.longitude))
                    .font(.caption)
                    .monospacedDigit()
                
                Text(point.timestamp.formatted(date: .omitted, time: .standard))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 속도
            if point.speed >= 0 {
                Text(String(format: "%.1f km/h", point.speedKmh))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 미리보기

#Preview {
    HistoryView()
        .environmentObject(LocationManager.shared)
}
