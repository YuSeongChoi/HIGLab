import Foundation
import CoreLocation

/// 위치 서비스를 관리하는 매니저 클래스
final class LocationManager: NSObject, ObservableObject {
    /// CLLocationManager 인스턴스
    private let manager = CLLocationManager()
    
    /// 현재 위치
    @Published var currentLocation: CLLocation?
    
    /// 권한 상태
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    /// 에러 메시지
    @Published var errorMessage: String?
    
    override init() {
        super.init()
        
        // delegate 설정
        manager.delegate = self
        
        // 정확도 설정 (러닝용 최고 정확도)
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        // 활동 유형 설정
        manager.activityType = .fitness
        
        // 현재 권한 상태 읽기
        authorizationStatus = manager.authorizationStatus
    }
}
