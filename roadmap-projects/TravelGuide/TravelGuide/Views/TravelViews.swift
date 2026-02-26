import SwiftUI
import MapKit
import CoreLocation
import WeatherKit
import EventKit

// MARK: - Map Explore View
struct MapExploreView: View {
    @State private var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedPlace: Place?
    
    let samplePlaces: [Place] = [
        Place(name: "경복궁", coordinate: CLLocationCoordinate2D(latitude: 37.579617, longitude: 126.977041), category: .landmark),
        Place(name: "남산타워", coordinate: CLLocationCoordinate2D(latitude: 37.551169, longitude: 126.988227), category: .landmark),
        Place(name: "명동", coordinate: CLLocationCoordinate2D(latitude: 37.563656, longitude: 126.983404), category: .shopping),
        Place(name: "홍대", coordinate: CLLocationCoordinate2D(latitude: 37.556724, longitude: 126.923677), category: .entertainment),
    ]
    
    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition) {
                // 현재 위치
                if let location = locationManager.currentLocation {
                    Annotation("내 위치", coordinate: location.coordinate) {
                        Circle()
                            .fill(.blue)
                            .frame(width: 12, height: 12)
                            .overlay(Circle().stroke(.white, lineWidth: 2))
                    }
                }
                
                // 명소 마커
                ForEach(samplePlaces) { place in
                    Annotation(place.name, coordinate: place.coordinate) {
                        Button {
                            selectedPlace = place
                        } label: {
                            Image(systemName: place.category.icon)
                                .font(.title2)
                                .foregroundStyle(.white)
                                .padding(8)
                                .background(place.category.color)
                                .clipShape(Circle())
                        }
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .navigationTitle("여행 지도")
            .toolbar {
                Button {
                    if let location = locationManager.currentLocation {
                        cameraPosition = .camera(MapCamera(centerCoordinate: location.coordinate, distance: 5000))
                    }
                } label: {
                    Image(systemName: "location")
                }
            }
            .onAppear {
                locationManager.requestAuthorization()
            }
            .sheet(item: $selectedPlace) { place in
                PlaceDetailSheet(place: place)
                    .presentationDetents([.medium])
            }
        }
    }
}

struct Place: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let category: PlaceCategory
    
    enum PlaceCategory {
        case landmark, restaurant, shopping, entertainment
        
        var icon: String {
            switch self {
            case .landmark: return "building.columns"
            case .restaurant: return "fork.knife"
            case .shopping: return "bag"
            case .entertainment: return "music.note"
            }
        }
        
        var color: Color {
            switch self {
            case .landmark: return .orange
            case .restaurant: return .red
            case .shopping: return .purple
            case .entertainment: return .pink
            }
        }
    }
}

struct PlaceDetailSheet: View {
    let place: Place
    @Environment(\.dismiss) private var dismiss
    @State private var eventManager = EventManager()
    @State private var showAddedAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: place.category.icon)
                        .font(.title)
                        .foregroundStyle(place.category.color)
                    
                    Text(place.name)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Text("위도: \(place.coordinate.latitude, specifier: "%.4f"), 경도: \(place.coordinate.longitude, specifier: "%.4f")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Divider()
                
                Button {
                    addToCalendar()
                } label: {
                    Label("일정에 추가", systemImage: "calendar.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("닫기") { dismiss() }
                }
            }
            .alert("일정 추가됨", isPresented: $showAddedAlert) {
                Button("확인", role: .cancel) { }
            }
        }
    }
    
    private func addToCalendar() {
        Task {
            if await eventManager.addEvent(title: "\(place.name) 방문", date: Date()) {
                showAddedAlert = true
            }
        }
    }
}

// MARK: - Weather View
struct WeatherView: View {
    @State private var weather: CurrentWeather?
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if isLoading {
                    ProgressView()
                } else if let weather {
                    VStack(spacing: 16) {
                        Image(systemName: weather.symbolName)
                            .font(.system(size: 80))
                            .symbolRenderingMode(.multicolor)
                        
                        Text("\(Int(weather.temperature.value))°")
                            .font(.system(size: 60, weight: .thin))
                        
                        Text(weather.condition.description)
                            .font(.title3)
                        
                        HStack(spacing: 30) {
                            WeatherStat(icon: "humidity", value: "\(Int(weather.humidity * 100))%", label: "습도")
                            WeatherStat(icon: "wind", value: "\(Int(weather.wind.speed.value)) m/s", label: "바람")
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "날씨 정보 없음",
                        systemImage: "cloud.sun",
                        description: Text("위치 권한이 필요합니다")
                    )
                }
            }
            .padding()
            .navigationTitle("날씨")
            .task {
                await fetchWeather()
            }
        }
    }
    
    private func fetchWeather() async {
        isLoading = true
        defer { isLoading = false }
        
        // 서울 기본 좌표
        let location = CLLocation(latitude: 37.5665, longitude: 126.9780)
        
        do {
            let service = WeatherService()
            let weather = try await service.weather(for: location)
            self.weather = weather.currentWeather
        } catch {
            print("날씨 조회 실패: \(error)")
        }
    }
}

struct WeatherStat: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Itinerary View
struct ItineraryView: View {
    @State private var eventManager = EventManager()
    @State private var events: [EKEvent] = []
    @State private var showAddEvent = false
    
    var body: some View {
        NavigationStack {
            Group {
                if events.isEmpty {
                    ContentUnavailableView(
                        "일정이 없습니다",
                        systemImage: "calendar",
                        description: Text("새 일정을 추가하세요")
                    )
                } else {
                    List(events, id: \.eventIdentifier) { event in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.title)
                                .font(.headline)
                            Text(event.startDate.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("여행 일정")
            .toolbar {
                Button {
                    showAddEvent = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .task {
                await eventManager.requestAccess()
                events = await eventManager.fetchUpcomingEvents()
            }
        }
    }
}

// MARK: - Location Manager
@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    var currentLocation: CLLocation?
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
}

// MARK: - Event Manager
@Observable
final class EventManager {
    private let store = EKEventStore()
    
    func requestAccess() async {
        try? await store.requestFullAccessToEvents()
    }
    
    func addEvent(title: String, date: Date) async -> Bool {
        try? await store.requestFullAccessToEvents()
        
        let event = EKEvent(eventStore: store)
        event.title = title
        event.startDate = date
        event.endDate = date.addingTimeInterval(3600)
        event.calendar = store.defaultCalendarForNewEvents
        
        do {
            try store.save(event, span: .thisEvent)
            return true
        } catch {
            return false
        }
    }
    
    func fetchUpcomingEvents() async -> [EKEvent] {
        let calendars = store.calendars(for: .event)
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate)!
        
        let predicate = store.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        return store.events(matching: predicate)
    }
}

#Preview {
    ContentView()
}
