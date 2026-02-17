// LocationService.swift
// GreenCharge - 위치 서비스
// iOS 26 CoreLocation 활용

import Foundation
import CoreLocation
import Observation

// MARK: - 위치 서비스

/// 위치 기반 전력망 예보를 위한 위치 서비스
@Observable
final class LocationService: NSObject {
    
    // MARK: - 속성
    
    /// CLLocationManager 인스턴스
    private let locationManager = CLLocationManager()
    
    /// 현재 위치
    private(set) var currentLocation: CLLocation?
    
    /// 현재 위치 이름 (역지오코딩 결과)
    private(set) var currentLocationName: String?
    
    /// 권한 상태
    private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    /// 위치 업데이트 중 여부
    private(set) var isUpdatingLocation = false
    
    /// 에러 메시지
    private(set) var errorMessage: String?
    
    /// 지오코더
    private let geocoder = CLGeocoder()
    
    // MARK: - 초기화
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer  // 전력망 예보는 km 단위로 충분
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // MARK: - 권한 요청
    
    /// 위치 권한 요청
    @MainActor
    func requestAuthorization() async {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted, .denied:
            errorMessage = "위치 권한이 거부되었습니다. 설정에서 권한을 허용해주세요."
            
        case .authorizedWhenInUse, .authorizedAlways:
            await startUpdatingLocation()
            
        @unknown default:
            break
        }
    }
    
    // MARK: - 위치 업데이트
    
    /// 위치 업데이트 시작
    @MainActor
    func startUpdatingLocation() async {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            await requestAuthorization()
            return
        }
        
        isUpdatingLocation = true
        errorMessage = nil
        
        // 한 번만 위치 가져오기
        locationManager.requestLocation()
    }
    
    /// 위치 업데이트 중지
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        isUpdatingLocation = false
    }
    
    // MARK: - 역지오코딩
    
    /// 좌표를 주소로 변환
    @MainActor
    private func reverseGeocode(_ location: CLLocation) async {
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            
            if let placemark = placemarks.first {
                // 지역 이름 조합
                var components: [String] = []
                
                if let locality = placemark.locality {
                    components.append(locality)
                }
                
                if let subLocality = placemark.subLocality {
                    components.append(subLocality)
                }
                
                currentLocationName = components.isEmpty ? "알 수 없는 위치" : components.joined(separator: " ")
            }
        } catch {
            currentLocationName = "위치 이름을 가져올 수 없음"
        }
    }
    
    // MARK: - 특정 위치 설정
    
    /// 특정 좌표로 위치 설정 (수동 선택용)
    @MainActor
    func setLocation(latitude: Double, longitude: Double) async {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        currentLocation = location
        await reverseGeocode(location)
    }
    
    /// 지역 이름으로 위치 설정
    @MainActor
    func setLocation(regionName: String) async {
        // 주요 도시 좌표 매핑
        let cityCoordinates: [String: (latitude: Double, longitude: Double)] = [
            "서울": (37.5665, 126.9780),
            "부산": (35.1796, 129.0756),
            "대구": (35.8714, 128.6014),
            "인천": (37.4563, 126.7052),
            "광주": (35.1595, 126.8526),
            "대전": (36.3504, 127.3845),
            "울산": (35.5384, 129.3114),
            "세종": (36.4800, 127.2890),
            "제주": (33.4996, 126.5312)
        ]
        
        if let coords = cityCoordinates[regionName] {
            await setLocation(latitude: coords.latitude, longitude: coords.longitude)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            currentLocation = location
            isUpdatingLocation = false
            await reverseGeocode(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            isUpdatingLocation = false
            
            if let clError = error as? CLError {
                switch clError.code {
                case .locationUnknown:
                    errorMessage = "현재 위치를 확인할 수 없습니다."
                case .denied:
                    errorMessage = "위치 권한이 거부되었습니다."
                case .network:
                    errorMessage = "네트워크 오류로 위치를 가져올 수 없습니다."
                default:
                    errorMessage = "위치 오류: \(clError.localizedDescription)"
                }
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
            
            if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
                await startUpdatingLocation()
            }
        }
    }
}

// MARK: - 위치 권한 상태 확장

extension CLAuthorizationStatus {
    /// 권한 상태 표시 문자열
    var displayString: String {
        switch self {
        case .notDetermined:
            return "미결정"
        case .restricted:
            return "제한됨"
        case .denied:
            return "거부됨"
        case .authorizedWhenInUse:
            return "사용 중 허용"
        case .authorizedAlways:
            return "항상 허용"
        @unknown default:
            return "알 수 없음"
        }
    }
    
    /// 권한이 부여되었는지 여부
    var isAuthorized: Bool {
        self == .authorizedWhenInUse || self == .authorizedAlways
    }
}
