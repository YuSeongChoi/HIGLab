import Foundation
import CoreLocation
import Combine

// MARK: - 위치 관리자
// CLLocationManager를 래핑하여 위치 추적 기능을 제공하는 클래스

/// 위치 관리 싱글톤 클래스
/// - 실시간 위치 업데이트
/// - 경로 기록
/// - 권한 관리
@MainActor
final class LocationManager: NSObject, ObservableObject {
    
    // MARK: - 싱글톤
    
    static let shared = LocationManager()
    
    // MARK: - Published Properties
    
    /// 현재 위치
    @Published private(set) var currentLocation: CLLocation?
    
    /// 현재 위치 포인트
    @Published private(set) var currentPoint: LocationPoint?
    
    /// 권한 상태
    @Published private(set) var permissionStatus: LocationPermissionStatus = .notDetermined
    
    /// 추적 중인지 여부
    @Published private(set) var isTracking = false
    
    /// 현재 활성 경로
    @Published private(set) var activeTrack: LocationTrack?
    
    /// 저장된 모든 경로
    @Published private(set) var savedTracks: [LocationTrack] = []
    
    /// 오류 메시지
    @Published private(set) var errorMessage: String?
    
    /// 설정
    @Published var settings = LocationSettings() {
        didSet {
            applySettings()
            saveSettings()
        }
    }
    
    // MARK: - Private Properties
    
    /// Core Location 관리자
    private let locationManager = CLLocationManager()
    
    /// 사용자 기본값 저장소
    private let defaults = UserDefaults.standard
    
    /// 추적 데이터 저장 키
    private let tracksKey = "savedLocationTracks"
    private let settingsKey = "locationSettings"
    
    // MARK: - 초기화
    
    private override init() {
        super.init()
        
        // CLLocationManager 설정
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.showsBackgroundLocationIndicator = true
        
        // 저장된 데이터 로드
        loadSettings()
        loadTracks()
        
        // 초기 권한 상태 확인
        updatePermissionStatus()
    }
    
    // MARK: - 권한 관리
    
    /// 권한 상태 업데이트
    private func updatePermissionStatus() {
        permissionStatus = LocationPermissionStatus(from: locationManager.authorizationStatus)
    }
    
    /// 위치 권한 요청 (사용 중일 때)
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// 위치 권한 요청 (항상)
    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    /// 설정 앱 열기
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    // MARK: - 위치 추적
    
    /// 위치 업데이트 시작
    func startUpdatingLocation() {
        guard permissionStatus.isAuthorized else {
            errorMessage = "위치 권한이 필요합니다."
            return
        }
        
        locationManager.startUpdatingLocation()
    }
    
    /// 위치 업데이트 중지
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    /// 단일 위치 요청
    func requestLocation() {
        guard permissionStatus.isAuthorized else {
            errorMessage = "위치 권한이 필요합니다."
            return
        }
        
        locationManager.requestLocation()
    }
    
    // MARK: - 경로 기록
    
    /// 경로 기록 시작
    func startTracking(name: String = "") {
        guard permissionStatus.isAuthorized else {
            errorMessage = "위치 권한이 필요합니다."
            return
        }
        
        // 새 경로 생성
        activeTrack = LocationTrack(name: name)
        isTracking = true
        
        // 위치 업데이트 시작
        startUpdatingLocation()
        
        print("📍 경로 기록 시작: \(activeTrack?.name ?? "")")
    }
    
    /// 경로 기록 중지
    func stopTracking() {
        guard var track = activeTrack else { return }
        
        // 경로 종료 처리
        track.endTime = Date()
        track.isActive = false
        
        // 저장
        if track.points.count > 1 {
            savedTracks.insert(track, at: 0)
            saveTracks()
            print("📍 경로 저장됨: \(track.name), 포인트: \(track.points.count)")
        } else {
            print("📍 포인트가 부족하여 저장하지 않음")
        }
        
        // 상태 초기화
        activeTrack = nil
        isTracking = false
        
        // 위치 업데이트 중지
        stopUpdatingLocation()
    }
    
    /// 경로 일시정지/재개
    func togglePauseTracking() {
        if isTracking {
            locationManager.stopUpdatingLocation()
            isTracking = false
        } else if activeTrack != nil {
            locationManager.startUpdatingLocation()
            isTracking = true
        }
    }
    
    /// 현재 위치를 활성 경로에 추가
    private func addPointToActiveTrack(_ location: CLLocation) {
        guard activeTrack != nil else { return }
        
        let point = LocationPoint(from: location)
        activeTrack?.points.append(point)
    }
    
    // MARK: - 데이터 관리
    
    /// 경로 삭제
    func deleteTrack(_ track: LocationTrack) {
        savedTracks.removeAll { $0.id == track.id }
        saveTracks()
    }
    
    /// 경로 이름 변경
    func renameTrack(_ track: LocationTrack, to newName: String) {
        guard let index = savedTracks.firstIndex(where: { $0.id == track.id }) else { return }
        savedTracks[index].name = newName
        saveTracks()
    }
    
    /// 모든 경로 삭제
    func deleteAllTracks() {
        savedTracks.removeAll()
        saveTracks()
    }
    
    // MARK: - 설정 적용
    
    /// 설정 적용
    private func applySettings() {
        locationManager.desiredAccuracy = settings.accuracyLevel.clAccuracy
        locationManager.distanceFilter = settings.distanceFilter
        locationManager.allowsBackgroundLocationUpdates = settings.backgroundUpdates
        locationManager.pausesLocationUpdatesAutomatically = settings.pausesAutomatically
        locationManager.showsBackgroundLocationIndicator = settings.showsBackgroundIndicator
    }
    
    // MARK: - 영구 저장
    
    /// 경로 저장
    private func saveTracks() {
        do {
            let data = try JSONEncoder().encode(savedTracks)
            defaults.set(data, forKey: tracksKey)
        } catch {
            print("❌ 경로 저장 실패: \(error)")
        }
    }
    
    /// 경로 로드
    private func loadTracks() {
        guard let data = defaults.data(forKey: tracksKey) else { return }
        
        do {
            savedTracks = try JSONDecoder().decode([LocationTrack].self, from: data)
        } catch {
            print("❌ 경로 로드 실패: \(error)")
        }
    }
    
    /// 설정 저장
    private func saveSettings() {
        do {
            let data = try JSONEncoder().encode(settings)
            defaults.set(data, forKey: settingsKey)
        } catch {
            print("❌ 설정 저장 실패: \(error)")
        }
    }
    
    /// 설정 로드
    private func loadSettings() {
        guard let data = defaults.data(forKey: settingsKey) else { return }
        
        do {
            settings = try JSONDecoder().decode(LocationSettings.self, from: data)
            applySettings()
        } catch {
            print("❌ 설정 로드 실패: \(error)")
        }
    }
    
    // MARK: - 유틸리티
    
    /// 두 위치 간 거리 계산 (미터)
    func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return toLocation.distance(from: fromLocation)
    }
    
    /// 오류 메시지 초기화
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    
    /// 권한 변경 시 호출
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            updatePermissionStatus()
            print("📍 권한 상태 변경: \(permissionStatus.displayText)")
        }
    }
    
    /// 위치 업데이트 시 호출
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            guard let location = locations.last else { return }
            
            // 현재 위치 업데이트
            currentLocation = location
            currentPoint = LocationPoint(from: location)
            
            // 활성 경로에 포인트 추가
            if isTracking {
                addPointToActiveTrack(location)
            }
        }
    }
    
    /// 위치 오류 시 호출
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    errorMessage = "위치 접근이 거부되었습니다."
                case .locationUnknown:
                    errorMessage = "현재 위치를 확인할 수 없습니다."
                case .network:
                    errorMessage = "네트워크 오류가 발생했습니다."
                default:
                    errorMessage = "위치 오류: \(clError.localizedDescription)"
                }
            } else {
                errorMessage = error.localizedDescription
            }
            print("❌ 위치 오류: \(error)")
        }
    }
}

// MARK: - Heading 지원 (선택적)

extension LocationManager {
    
    /// 방향 업데이트 시작 (나침반)
    func startUpdatingHeading() {
        guard CLLocationManager.headingAvailable() else {
            errorMessage = "이 기기는 방향 측정을 지원하지 않습니다."
            return
        }
        locationManager.startUpdatingHeading()
    }
    
    /// 방향 업데이트 중지
    func stopUpdatingHeading() {
        locationManager.stopUpdatingHeading()
    }
}

// MARK: - Significant Location Changes

extension LocationManager {
    
    /// 중요 위치 변경 모니터링 시작
    /// - 배터리 효율적이지만 정확도는 낮음
    func startMonitoringSignificantLocationChanges() {
        guard CLLocationManager.significantLocationChangeMonitoringAvailable() else {
            errorMessage = "중요 위치 변경 모니터링을 지원하지 않습니다."
            return
        }
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    /// 중요 위치 변경 모니터링 중지
    func stopMonitoringSignificantLocationChanges() {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
}
