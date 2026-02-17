import Foundation
import CoreLocation
import UserNotifications

// MARK: - 지오펜싱 관리자
// 지오펜스 영역을 관리하고 진입/이탈 이벤트를 처리하는 클래스

/// 지오펜스 관리 싱글톤 클래스
/// - 지오펜스 등록/삭제
/// - 진입/이탈 이벤트 모니터링
/// - 로컬 알림 발송
@MainActor
final class GeofenceManager: NSObject, ObservableObject {
    
    // MARK: - 싱글톤
    
    static let shared = GeofenceManager()
    
    // MARK: - Published Properties
    
    /// 등록된 지오펜스 목록
    @Published private(set) var geofences: [GeofenceRegion] = []
    
    /// 지오펜스 이벤트 기록
    @Published private(set) var events: [GeofenceEvent] = []
    
    /// 오류 메시지
    @Published private(set) var errorMessage: String?
    
    // MARK: - Private Properties
    
    /// Core Location 관리자
    private let locationManager = CLLocationManager()
    
    /// 사용자 기본값 저장소
    private let defaults = UserDefaults.standard
    
    /// 저장 키
    private let geofencesKey = "savedGeofences"
    private let eventsKey = "geofenceEvents"
    
    /// 최대 지오펜스 개수 (iOS 제한)
    let maxGeofenceCount = 20
    
    // MARK: - 초기화
    
    private override init() {
        super.init()
        
        locationManager.delegate = self
        
        // 저장된 데이터 로드
        loadGeofences()
        loadEvents()
        
        // 알림 권한 요청
        requestNotificationPermission()
        
        // 기존 지오펜스 재등록 (앱 재시작 시)
        reregisterAllGeofences()
    }
    
    // MARK: - 알림 권한
    
    /// 알림 권한 요청
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ 알림 권한 요청 실패: \(error)")
            } else {
                print("📍 알림 권한: \(granted ? "허용" : "거부")")
            }
        }
    }
    
    // MARK: - 지오펜스 관리
    
    /// 새 지오펜스 추가
    /// - Parameters:
    ///   - name: 지오펜스 이름
    ///   - coordinate: 중심 좌표
    ///   - radius: 반경 (미터, 기본 100m)
    ///   - notifyOnEntry: 진입 시 알림
    ///   - notifyOnExit: 이탈 시 알림
    /// - Returns: 추가 성공 여부
    @discardableResult
    func addGeofence(
        name: String,
        coordinate: CLLocationCoordinate2D,
        radius: Double = 100,
        notifyOnEntry: Bool = true,
        notifyOnExit: Bool = true
    ) -> Bool {
        // 개수 제한 확인
        guard geofences.count < maxGeofenceCount else {
            errorMessage = "최대 \(maxGeofenceCount)개의 지오펜스만 등록할 수 있습니다."
            return false
        }
        
        // 반경 제한 확인 (iOS 최소 100m 권장)
        let validRadius = max(100, min(radius, locationManager.maximumRegionMonitoringDistance))
        
        // 새 지오펜스 생성
        let geofence = GeofenceRegion(
            name: name,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            radius: validRadius,
            notifyOnEntry: notifyOnEntry,
            notifyOnExit: notifyOnExit
        )
        
        // 모니터링 시작
        startMonitoring(geofence)
        
        // 목록에 추가
        geofences.append(geofence)
        saveGeofences()
        
        print("📍 지오펜스 추가됨: \(name), 반경: \(validRadius)m")
        return true
    }
    
    /// 지오펜스 삭제
    func removeGeofence(_ geofence: GeofenceRegion) {
        // 모니터링 중지
        stopMonitoring(geofence)
        
        // 목록에서 제거
        geofences.removeAll { $0.id == geofence.id }
        saveGeofences()
        
        print("📍 지오펜스 삭제됨: \(geofence.name)")
    }
    
    /// ID로 지오펜스 삭제
    func removeGeofence(withId id: UUID) {
        guard let geofence = geofences.first(where: { $0.id == id }) else { return }
        removeGeofence(geofence)
    }
    
    /// 모든 지오펜스 삭제
    func removeAllGeofences() {
        for geofence in geofences {
            stopMonitoring(geofence)
        }
        geofences.removeAll()
        saveGeofences()
        
        print("📍 모든 지오펜스 삭제됨")
    }
    
    /// 지오펜스 활성화/비활성화 토글
    func toggleGeofence(_ geofence: GeofenceRegion) {
        guard let index = geofences.firstIndex(where: { $0.id == geofence.id }) else { return }
        
        geofences[index].isEnabled.toggle()
        
        if geofences[index].isEnabled {
            startMonitoring(geofences[index])
        } else {
            stopMonitoring(geofences[index])
        }
        
        saveGeofences()
    }
    
    /// 지오펜스 수정
    func updateGeofence(_ geofence: GeofenceRegion) {
        guard let index = geofences.firstIndex(where: { $0.id == geofence.id }) else { return }
        
        // 기존 모니터링 중지
        stopMonitoring(geofences[index])
        
        // 업데이트
        geofences[index] = geofence
        
        // 새로 모니터링 시작
        if geofence.isEnabled {
            startMonitoring(geofence)
        }
        
        saveGeofences()
    }
    
    // MARK: - 모니터링
    
    /// 지오펜스 모니터링 시작
    private func startMonitoring(_ geofence: GeofenceRegion) {
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            errorMessage = "이 기기는 지오펜스 모니터링을 지원하지 않습니다."
            return
        }
        
        let region = geofence.clRegion
        locationManager.startMonitoring(for: region)
        
        // 현재 상태 확인 요청
        locationManager.requestState(for: region)
    }
    
    /// 지오펜스 모니터링 중지
    private func stopMonitoring(_ geofence: GeofenceRegion) {
        let region = geofence.clRegion
        locationManager.stopMonitoring(for: region)
    }
    
    /// 모든 지오펜스 재등록
    private func reregisterAllGeofences() {
        for geofence in geofences where geofence.isEnabled {
            startMonitoring(geofence)
        }
    }
    
    // MARK: - 이벤트 처리
    
    /// 지오펜스 이벤트 기록
    private func recordEvent(regionId: String, type: GeofenceEvent.EventType) {
        guard let uuid = UUID(uuidString: regionId),
              let geofence = geofences.first(where: { $0.id == uuid }) else {
            return
        }
        
        let event = GeofenceEvent(
            regionId: uuid,
            regionName: geofence.name,
            eventType: type
        )
        
        events.insert(event, at: 0)
        
        // 최대 100개 유지
        if events.count > 100 {
            events = Array(events.prefix(100))
        }
        
        saveEvents()
        
        // 알림 발송
        sendNotification(for: event, geofence: geofence)
        
        print("📍 지오펜스 이벤트: \(geofence.name) - \(type.rawValue)")
    }
    
    /// 로컬 알림 발송
    private func sendNotification(for event: GeofenceEvent, geofence: GeofenceRegion) {
        let content = UNMutableNotificationContent()
        content.title = "위치 알림"
        content.body = "\(geofence.name)에 \(event.eventType.rawValue)했습니다."
        content.sound = .default
        content.badge = 1
        
        let request = UNNotificationRequest(
            identifier: event.id.uuidString,
            content: content,
            trigger: nil // 즉시 발송
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 알림 발송 실패: \(error)")
            }
        }
    }
    
    /// 이벤트 기록 삭제
    func clearEvents() {
        events.removeAll()
        saveEvents()
    }
    
    // MARK: - 영구 저장
    
    /// 지오펜스 저장
    private func saveGeofences() {
        do {
            let data = try JSONEncoder().encode(geofences)
            defaults.set(data, forKey: geofencesKey)
        } catch {
            print("❌ 지오펜스 저장 실패: \(error)")
        }
    }
    
    /// 지오펜스 로드
    private func loadGeofences() {
        guard let data = defaults.data(forKey: geofencesKey) else { return }
        
        do {
            geofences = try JSONDecoder().decode([GeofenceRegion].self, from: data)
        } catch {
            print("❌ 지오펜스 로드 실패: \(error)")
        }
    }
    
    /// 이벤트 저장
    private func saveEvents() {
        do {
            let data = try JSONEncoder().encode(events)
            defaults.set(data, forKey: eventsKey)
        } catch {
            print("❌ 이벤트 저장 실패: \(error)")
        }
    }
    
    /// 이벤트 로드
    private func loadEvents() {
        guard let data = defaults.data(forKey: eventsKey) else { return }
        
        do {
            events = try JSONDecoder().decode([GeofenceEvent].self, from: data)
        } catch {
            print("❌ 이벤트 로드 실패: \(error)")
        }
    }
    
    // MARK: - 유틸리티
    
    /// 현재 위치가 지오펜스 내부인지 확인
    func isInsideGeofence(_ geofence: GeofenceRegion, location: CLLocation) -> Bool {
        let geofenceLocation = CLLocation(
            latitude: geofence.latitude,
            longitude: geofence.longitude
        )
        let distance = location.distance(from: geofenceLocation)
        return distance <= geofence.radius
    }
    
    /// 오류 메시지 초기화
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - CLLocationManagerDelegate

extension GeofenceManager: CLLocationManagerDelegate {
    
    /// 지역 진입 시 호출
    nonisolated func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        Task { @MainActor in
            guard let circularRegion = region as? CLCircularRegion else { return }
            recordEvent(regionId: circularRegion.identifier, type: .enter)
        }
    }
    
    /// 지역 이탈 시 호출
    nonisolated func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        Task { @MainActor in
            guard let circularRegion = region as? CLCircularRegion else { return }
            recordEvent(regionId: circularRegion.identifier, type: .exit)
        }
    }
    
    /// 지역 상태 확인 시 호출
    nonisolated func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        Task { @MainActor in
            let stateText: String
            switch state {
            case .inside:
                stateText = "내부"
            case .outside:
                stateText = "외부"
            case .unknown:
                stateText = "알 수 없음"
            }
            print("📍 지역 상태: \(region.identifier) - \(stateText)")
        }
    }
    
    /// 모니터링 시작 시 호출
    nonisolated func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("📍 모니터링 시작: \(region.identifier)")
    }
    
    /// 모니터링 실패 시 호출
    nonisolated func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        Task { @MainActor in
            errorMessage = "지오펜스 모니터링 실패: \(error.localizedDescription)"
            print("❌ 모니터링 실패: \(region?.identifier ?? "unknown") - \(error)")
        }
    }
}
