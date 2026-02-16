import WeatherKit
import CoreLocation
import Foundation

// 다양한 에러 타입 처리

enum WeatherFetchError: LocalizedError {
    case permissionDenied
    case networkError(Error)
    case locationError
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "날씨 서비스 권한이 거부되었습니다."
        case .networkError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        case .locationError:
            return "위치를 확인할 수 없습니다."
        case .unknown(let error):
            return "알 수 없는 오류: \(error.localizedDescription)"
        }
    }
}

func categorizeError(_ error: Error) -> WeatherFetchError {
    if let weatherError = error as? WeatherError {
        switch weatherError {
        case .permissionDenied:
            return .permissionDenied
        default:
            return .unknown(error)
        }
    }
    
    if let urlError = error as? URLError {
        return .networkError(urlError)
    }
    
    return .unknown(error)
}
