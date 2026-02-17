import Foundation
import CoreLocation

// MARK: - 위치 기록 데이터 모델
// 사용자의 위치 정보를 저장하고 관리하기 위한 데이터 구조체들

/// 단일 위치 포인트
/// - 위도, 경도, 고도, 정확도, 타임스탬프를 포함
struct LocationPoint: Identifiable, Codable, Equatable {
    let id: UUID
    let latitude: Double      // 위도
    let longitude: Double     // 경도
    let altitude: Double      // 고도 (미터)
    let horizontalAccuracy: Double  // 수평 정확도
    let verticalAccuracy: Double    // 수직 정확도
    let timestamp: Date       // 기록 시간
    let speed: Double         // 속도 (m/s)
    let course: Double        // 진행 방향 (도)
    
    init(
        id: UUID = UUID(),
        latitude: Double,
        longitude: Double,
        altitude: Double = 0,
        horizontalAccuracy: Double = 0,
        verticalAccuracy: Double = 0,
        timestamp: Date = Date(),
        speed: Double = -1,
        course: Double = -1
    ) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.horizontalAccuracy = horizontalAccuracy
        self.verticalAccuracy = verticalAccuracy
        self.timestamp = timestamp
        self.speed = speed
        self.course = course
    }
    
    /// CLLocation으로부터 생성
    init(from location: CLLocation) {
        self.id = UUID()
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.altitude = location.altitude
        self.horizontalAccuracy = location.horizontalAccuracy
        self.verticalAccuracy = location.verticalAccuracy
        self.timestamp = location.timestamp
        self.speed = location.speed
        self.course = location.course
    }
    
    /// CLLocationCoordinate2D 반환
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    /// CLLocation으로 변환
    var clLocation: CLLocation {
        CLLocation(
            coordinate: coordinate,
            altitude: altitude,
            horizontalAccuracy: horizontalAccuracy,
            verticalAccuracy: verticalAccuracy,
            course: course,
            speed: speed,
            timestamp: timestamp
        )
    }
    
    /// 속도를 km/h로 반환
    var speedKmh: Double {
        guard speed >= 0 else { return 0 }
        return speed * 3.6
    }
    
    /// 진행 방향을 문자열로 반환
    var courseDirection: String {
        guard course >= 0 else { return "알 수 없음" }
        
        switch course {
        case 0..<22.5, 337.5...360:
            return "북"
        case 22.5..<67.5:
            return "북동"
        case 67.5..<112.5:
            return "동"
        case 112.5..<157.5:
            return "남동"
        case 157.5..<202.5:
            return "남"
        case 202.5..<247.5:
            return "남서"
        case 247.5..<292.5:
            return "서"
        case 292.5..<337.5:
            return "북서"
        default:
            return "알 수 없음"
        }
    }
}

// MARK: - 경로 트랙

/// 여러 위치 포인트로 구성된 경로
struct LocationTrack: Identifiable, Codable {
    let id: UUID
    var name: String           // 경로 이름
    var points: [LocationPoint] // 위치 포인트 배열
    let startTime: Date        // 시작 시간
    var endTime: Date?         // 종료 시간
    var isActive: Bool         // 현재 기록 중인지 여부
    
    init(
        id: UUID = UUID(),
        name: String = "",
        points: [LocationPoint] = [],
        startTime: Date = Date(),
        endTime: Date? = nil,
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name.isEmpty ? Self.defaultName(for: startTime) : name
        self.points = points
        self.startTime = startTime
        self.endTime = endTime
        self.isActive = isActive
    }
    
    /// 기본 이름 생성 (날짜 기반)
    static func defaultName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 HH:mm 경로"
        return formatter.string(from: date)
    }
    
    /// 총 이동 거리 (미터)
    var totalDistance: Double {
        guard points.count > 1 else { return 0 }
        
        var distance: Double = 0
        for i in 1..<points.count {
            let from = points[i - 1].clLocation
            let to = points[i].clLocation
            distance += to.distance(from: from)
        }
        return distance
    }
    
    /// 총 이동 거리 (킬로미터)
    var totalDistanceKm: Double {
        totalDistance / 1000.0
    }
    
    /// 총 소요 시간 (초)
    var duration: TimeInterval {
        guard let first = points.first,
              let last = points.last else { return 0 }
        return last.timestamp.timeIntervalSince(first.timestamp)
    }
    
    /// 소요 시간 포맷팅
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d시간 %d분", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%d분 %d초", minutes, seconds)
        } else {
            return String(format: "%d초", seconds)
        }
    }
    
    /// 평균 속도 (km/h)
    var averageSpeed: Double {
        guard duration > 0 else { return 0 }
        return (totalDistance / duration) * 3.6
    }
    
    /// 최고 속도 (km/h)
    var maxSpeed: Double {
        let validSpeeds = points.compactMap { $0.speed >= 0 ? $0.speedKmh : nil }
        return validSpeeds.max() ?? 0
    }
}

// MARK: - 지오펜스 데이터

/// 지오펜스 영역
struct GeofenceRegion: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String           // 지오펜스 이름
    let latitude: Double       // 중심 위도
    let longitude: Double      // 중심 경도
    var radius: Double         // 반경 (미터)
    var notifyOnEntry: Bool    // 진입 시 알림
    var notifyOnExit: Bool     // 이탈 시 알림
    var isEnabled: Bool        // 활성화 여부
    let createdAt: Date        // 생성 시간
    
    init(
        id: UUID = UUID(),
        name: String,
        latitude: Double,
        longitude: Double,
        radius: Double = 100,
        notifyOnEntry: Bool = true,
        notifyOnExit: Bool = true,
        isEnabled: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        self.notifyOnEntry = notifyOnEntry
        self.notifyOnExit = notifyOnExit
        self.isEnabled = isEnabled
        self.createdAt = createdAt
    }
    
    /// CLLocationCoordinate2D 반환
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    /// CLCircularRegion으로 변환
    var clRegion: CLCircularRegion {
        let region = CLCircularRegion(
            center: coordinate,
            radius: radius,
            identifier: id.uuidString
        )
        region.notifyOnEntry = notifyOnEntry
        region.notifyOnExit = notifyOnExit
        return region
    }
}

// MARK: - 지오펜스 이벤트

/// 지오펜스 진입/이탈 이벤트
struct GeofenceEvent: Identifiable, Codable {
    let id: UUID
    let regionId: UUID         // 관련 지오펜스 ID
    let regionName: String     // 지오펜스 이름
    let eventType: EventType   // 이벤트 유형
    let timestamp: Date        // 발생 시간
    
    enum EventType: String, Codable {
        case enter = "진입"
        case exit = "이탈"
    }
    
    init(
        id: UUID = UUID(),
        regionId: UUID,
        regionName: String,
        eventType: EventType,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.regionId = regionId
        self.regionName = regionName
        self.eventType = eventType
        self.timestamp = timestamp
    }
}

// MARK: - 설정 데이터

/// 앱 설정
struct LocationSettings: Codable {
    var accuracyLevel: AccuracyLevel = .best           // 위치 정확도
    var distanceFilter: Double = 10                     // 최소 이동 거리 (미터)
    var backgroundUpdates: Bool = true                  // 백그라운드 업데이트
    var showsBackgroundIndicator: Bool = true           // 백그라운드 인디케이터
    var pausesAutomatically: Bool = false               // 자동 일시정지
    var trackingInterval: Double = 5                    // 추적 간격 (초)
    var maxGeofenceCount: Int = 20                      // 최대 지오펜스 개수
    
    /// 위치 정확도 레벨
    enum AccuracyLevel: String, Codable, CaseIterable {
        case best = "최고 정확도"
        case nearestTenMeters = "10미터 이내"
        case hundredMeters = "100미터 이내"
        case kilometer = "1킬로미터 이내"
        case threeKilometers = "3킬로미터 이내"
        
        /// CLLocationAccuracy로 변환
        var clAccuracy: CLLocationAccuracy {
            switch self {
            case .best:
                return kCLLocationAccuracyBest
            case .nearestTenMeters:
                return kCLLocationAccuracyNearestTenMeters
            case .hundredMeters:
                return kCLLocationAccuracyHundredMeters
            case .kilometer:
                return kCLLocationAccuracyKilometer
            case .threeKilometers:
                return kCLLocationAccuracyThreeKilometers
            }
        }
    }
}

// MARK: - 권한 상태

/// 위치 권한 상태
enum LocationPermissionStatus {
    case notDetermined      // 아직 결정되지 않음
    case restricted         // 제한됨 (보호자 통제 등)
    case denied             // 거부됨
    case authorizedAlways   // 항상 허용
    case authorizedWhenInUse // 사용 중일 때만 허용
    
    /// CLAuthorizationStatus에서 변환
    init(from status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            self = .notDetermined
        case .restricted:
            self = .restricted
        case .denied:
            self = .denied
        case .authorizedAlways:
            self = .authorizedAlways
        case .authorizedWhenInUse:
            self = .authorizedWhenInUse
        @unknown default:
            self = .notDetermined
        }
    }
    
    /// 권한이 허용되었는지 여부
    var isAuthorized: Bool {
        self == .authorizedAlways || self == .authorizedWhenInUse
    }
    
    /// 표시 문자열
    var displayText: String {
        switch self {
        case .notDetermined:
            return "권한 요청 필요"
        case .restricted:
            return "사용 제한됨"
        case .denied:
            return "권한 거부됨"
        case .authorizedAlways:
            return "항상 허용"
        case .authorizedWhenInUse:
            return "사용 중 허용"
        }
    }
}
