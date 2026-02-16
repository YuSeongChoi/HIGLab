import WeatherKit
import SwiftUI

// 사용자 친화적인 에러 메시지

struct WeatherErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: errorIcon)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text(errorTitle)
                .font(.headline)
            
            Text(errorMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button("다시 시도", action: retryAction)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private var errorIcon: String {
        if error is WeatherError {
            return "cloud.slash"
        }
        return "wifi.slash"
    }
    
    private var errorTitle: String {
        if let weatherError = error as? WeatherError,
           case .permissionDenied = weatherError {
            return "권한 필요"
        }
        return "날씨를 불러올 수 없음"
    }
    
    private var errorMessage: String {
        if let weatherError = error as? WeatherError,
           case .permissionDenied = weatherError {
            return "날씨 서비스를 사용하려면 앱 설정을 확인해주세요."
        }
        return "인터넷 연결을 확인하고 다시 시도해주세요."
    }
}
