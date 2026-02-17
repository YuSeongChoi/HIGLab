import SwiftUI

// MARK: - 앱 진입점
// LocationTracker 앱의 메인 진입점

/// 앱 메인 구조체
/// - 앱 라이프사이클 관리
/// - 매니저 초기화
@main
struct LocationTrackerApp: App {
    
    // MARK: - State Objects
    
    /// 위치 관리자 (싱글톤)
    @StateObject private var locationManager = LocationManager.shared
    
    /// 지오펜스 관리자 (싱글톤)
    @StateObject private var geofenceManager = GeofenceManager.shared
    
    // MARK: - Scene
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
                .environmentObject(geofenceManager)
        }
    }
}

// MARK: - 미리보기용 확장

#if DEBUG
/// 미리보기용 목업 데이터
extension LocationPoint {
    static let preview = LocationPoint(
        latitude: 37.5665,
        longitude: 126.9780,
        altitude: 38,
        horizontalAccuracy: 5,
        verticalAccuracy: 3,
        timestamp: Date(),
        speed: 4.5,
        course: 45
    )
}

extension LocationTrack {
    static let preview: LocationTrack = {
        var track = LocationTrack(name: "테스트 경로")
        track.points = [
            LocationPoint(latitude: 37.5665, longitude: 126.9780, timestamp: Date().addingTimeInterval(-3600)),
            LocationPoint(latitude: 37.5670, longitude: 126.9785, timestamp: Date().addingTimeInterval(-3000)),
            LocationPoint(latitude: 37.5675, longitude: 126.9790, timestamp: Date().addingTimeInterval(-2400)),
            LocationPoint(latitude: 37.5680, longitude: 126.9795, timestamp: Date().addingTimeInterval(-1800)),
            LocationPoint(latitude: 37.5685, longitude: 126.9800, timestamp: Date())
        ]
        return track
    }()
}

extension GeofenceRegion {
    static let preview = GeofenceRegion(
        name: "집",
        latitude: 37.5665,
        longitude: 126.9780,
        radius: 100
    )
}
#endif
