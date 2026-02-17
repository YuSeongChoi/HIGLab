import SwiftUI
import MapKit

// MARK: - 지오펜스 설정 뷰
// 지오펜스를 추가, 편집, 삭제하는 화면

struct GeofenceSetupView: View {
    
    // MARK: - Environment
    
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var geofenceManager: GeofenceManager
    
    // MARK: - State
    
    /// 새 지오펜스 추가 시트 표시
    @State private var showAddSheet = false
    
    /// 지오펜스 이벤트 목록 시트 표시
    @State private var showEventsSheet = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                // 지오펜스 목록 섹션
                if !geofenceManager.geofences.isEmpty {
                    Section {
                        ForEach(geofenceManager.geofences) { geofence in
                            GeofenceRow(geofence: geofence)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        geofenceManager.removeGeofence(geofence)
                                    } label: {
                                        Label("삭제", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        geofenceManager.toggleGeofence(geofence)
                                    } label: {
                                        Label(
                                            geofence.isEnabled ? "비활성화" : "활성화",
                                            systemImage: geofence.isEnabled ? "pause" : "play"
                                        )
                                    }
                                    .tint(geofence.isEnabled ? .orange : .green)
                                }
                        }
                    } header: {
                        Text("등록된 지오펜스")
                    } footer: {
                        Text("최대 \(geofenceManager.maxGeofenceCount)개까지 등록할 수 있습니다. (현재 \(geofenceManager.geofences.count)개)")
                    }
                }
                
                // 빈 상태
                if geofenceManager.geofences.isEmpty {
                    Section {
                        VStack(spacing: 16) {
                            Image(systemName: "mappin.circle")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            
                            Text("등록된 지오펜스가 없습니다")
                                .font(.headline)
                            
                            Text("지오펜스를 추가하여 특정 위치 진입/이탈 시 알림을 받을 수 있습니다.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button {
                                showAddSheet = true
                            } label: {
                                Label("지오펜스 추가", systemImage: "plus")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                }
                
                // 최근 이벤트 섹션
                Section {
                    if geofenceManager.events.isEmpty {
                        Text("아직 이벤트가 없습니다")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(geofenceManager.events.prefix(5)) { event in
                            EventRow(event: event)
                        }
                        
                        if geofenceManager.events.count > 5 {
                            Button {
                                showEventsSheet = true
                            } label: {
                                Text("모든 이벤트 보기 (\(geofenceManager.events.count)개)")
                            }
                        }
                    }
                } header: {
                    Text("최근 이벤트")
                }
                
                // 정보 섹션
                Section {
                    InfoRow(
                        icon: "info.circle",
                        title: "지오펜싱이란?",
                        description: "특정 지역에 진입하거나 이탈할 때 알림을 받는 기능입니다."
                    )
                    
                    InfoRow(
                        icon: "battery.100",
                        title: "배터리 효율",
                        description: "지오펜싱은 GPS를 지속적으로 사용하지 않아 배터리를 절약합니다."
                    )
                    
                    InfoRow(
                        icon: "location.fill",
                        title: "백그라운드 동작",
                        description: "'항상 허용' 권한이 있으면 앱이 종료되어도 알림을 받을 수 있습니다."
                    )
                } header: {
                    Text("정보")
                }
            }
            .navigationTitle("지오펜스")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(geofenceManager.geofences.count >= geofenceManager.maxGeofenceCount)
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddGeofenceView()
            }
            .sheet(isPresented: $showEventsSheet) {
                EventListView()
            }
            .alert("오류", isPresented: .constant(geofenceManager.errorMessage != nil)) {
                Button("확인") {
                    geofenceManager.clearError()
                }
            } message: {
                Text(geofenceManager.errorMessage ?? "")
            }
        }
    }
}

// MARK: - 지오펜스 행

/// 지오펜스 목록 행 컴포넌트
struct GeofenceRow: View {
    let geofence: GeofenceRegion
    
    var body: some View {
        HStack(spacing: 12) {
            // 아이콘
            ZStack {
                Circle()
                    .fill(geofence.isEnabled ? .blue.opacity(0.2) : .gray.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "mappin.circle.fill")
                    .font(.title2)
                    .foregroundColor(geofence.isEnabled ? .blue : .gray)
            }
            
            // 정보
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(geofence.name)
                        .font(.headline)
                    
                    if !geofence.isEnabled {
                        Text("비활성")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.gray.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                
                Text("반경 \(Int(geofence.radius))m")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // 알림 설정 표시
                HStack(spacing: 8) {
                    if geofence.notifyOnEntry {
                        Label("진입", systemImage: "arrow.down.circle")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                    if geofence.notifyOnExit {
                        Label("이탈", systemImage: "arrow.up.circle")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
            // 좌표 정보
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.4f", geofence.latitude))
                Text(String(format: "%.4f", geofence.longitude))
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .monospacedDigit()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 이벤트 행

/// 이벤트 목록 행 컴포넌트
struct EventRow: View {
    let event: GeofenceEvent
    
    var body: some View {
        HStack(spacing: 12) {
            // 아이콘
            Image(systemName: event.eventType == .enter ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                .font(.title2)
                .foregroundColor(event.eventType == .enter ? .green : .orange)
            
            // 정보
            VStack(alignment: .leading, spacing: 2) {
                Text(event.regionName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(event.eventType.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 시간
            Text(event.timestamp.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - 정보 행

/// 정보 표시 행 컴포넌트
struct InfoRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 지오펜스 추가 뷰

/// 새 지오펜스를 추가하는 시트
struct AddGeofenceView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var geofenceManager: GeofenceManager
    
    // MARK: - State
    
    @State private var name = ""
    @State private var radius: Double = 100
    @State private var notifyOnEntry = true
    @State private var notifyOnExit = true
    
    /// 지도에서 선택한 좌표
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    
    /// 지도 카메라 위치
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                // 지도 섹션
                Section {
                    // 지도 뷰
                    Map(position: $cameraPosition, interactionModes: .all) {
                        // 현재 위치
                        if let location = locationManager.currentLocation {
                            Annotation("현재 위치", coordinate: location.coordinate) {
                                CurrentLocationMarker()
                            }
                        }
                        
                        // 선택된 위치와 반경
                        if let coordinate = selectedCoordinate {
                            // 반경 원
                            MapCircle(center: coordinate, radius: radius)
                                .foregroundStyle(.blue.opacity(0.2))
                                .stroke(.blue, lineWidth: 2)
                            
                            // 중심점
                            Annotation("", coordinate: coordinate) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onTapGesture { location in
                        // 탭한 위치로 좌표 설정 (실제로는 MapReader 사용 필요)
                    }
                    
                    // 현재 위치 사용 버튼
                    Button {
                        useCurrentLocation()
                    } label: {
                        Label("현재 위치 사용", systemImage: "location.fill")
                    }
                    
                    // 선택된 좌표 표시
                    if let coordinate = selectedCoordinate {
                        HStack {
                            Text("선택된 위치")
                            Spacer()
                            Text(String(format: "%.6f, %.6f", coordinate.latitude, coordinate.longitude))
                                .font(.caption)
                                .monospacedDigit()
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("위치 선택")
                } footer: {
                    Text("'현재 위치 사용' 버튼을 눌러 현재 위치를 지오펜스 중심으로 설정하세요.")
                }
                
                // 이름 섹션
                Section("지오펜스 이름") {
                    TextField("예: 집, 회사, 학교", text: $name)
                }
                
                // 반경 섹션
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("반경")
                            Spacer()
                            Text("\(Int(radius))m")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $radius, in: 100...1000, step: 50)
                    }
                } header: {
                    Text("반경 설정")
                } footer: {
                    Text("최소 100m부터 1km까지 설정할 수 있습니다.")
                }
                
                // 알림 설정 섹션
                Section("알림 설정") {
                    Toggle("진입 시 알림", isOn: $notifyOnEntry)
                    Toggle("이탈 시 알림", isOn: $notifyOnExit)
                }
            }
            .navigationTitle("지오펜스 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("추가") {
                        addGeofence()
                    }
                    .disabled(!canAdd)
                }
            }
            .onAppear {
                // 초기 위치 설정
                if let location = locationManager.currentLocation {
                    cameraPosition = .region(MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    ))
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// 추가 가능 여부
    private var canAdd: Bool {
        !name.isEmpty && selectedCoordinate != nil && (notifyOnEntry || notifyOnExit)
    }
    
    // MARK: - Methods
    
    /// 현재 위치 사용
    private func useCurrentLocation() {
        guard let location = locationManager.currentLocation else { return }
        selectedCoordinate = location.coordinate
        
        cameraPosition = .region(MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        ))
    }
    
    /// 지오펜스 추가
    private func addGeofence() {
        guard let coordinate = selectedCoordinate else { return }
        
        geofenceManager.addGeofence(
            name: name,
            coordinate: coordinate,
            radius: radius,
            notifyOnEntry: notifyOnEntry,
            notifyOnExit: notifyOnExit
        )
        
        dismiss()
    }
}

// MARK: - 이벤트 목록 뷰

/// 모든 지오펜스 이벤트를 표시하는 시트
struct EventListView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var geofenceManager: GeofenceManager
    
    var body: some View {
        NavigationStack {
            List {
                if geofenceManager.events.isEmpty {
                    Text("이벤트가 없습니다")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(geofenceManager.events) { event in
                        EventRow(event: event)
                    }
                }
            }
            .navigationTitle("이벤트 기록")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("모두 삭제", role: .destructive) {
                        geofenceManager.clearEvents()
                    }
                    .disabled(geofenceManager.events.isEmpty)
                }
            }
        }
    }
}

// MARK: - 미리보기

#Preview {
    GeofenceSetupView()
        .environmentObject(LocationManager.shared)
        .environmentObject(GeofenceManager.shared)
}
