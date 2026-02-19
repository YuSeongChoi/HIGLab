#if canImport(PermissionKit)
import PermissionKit
import CoreLocation
import SwiftUI

// 위치 정확도 권한 관리
@Observable
final class LocationAccuracyManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    var accuracyAuthorization: CLAccuracyAuthorization = .reducedAccuracy
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    var isPreciseLocationEnabled: Bool {
        accuracyAuthorization == .fullAccuracy
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        refreshStatus()
    }
    
    func refreshStatus() {
        authorizationStatus = locationManager.authorizationStatus
        accuracyAuthorization = locationManager.accuracyAuthorization
    }
    
    /// 일시적으로 정확한 위치 요청 (iOS 14+)
    /// 사용자가 대략적 위치만 허용한 경우, 특정 기능을 위해 정확한 위치를 요청
    func requestTemporaryFullAccuracy(purposeKey: String) async throws {
        try await locationManager.requestTemporaryFullAccuracyAuthorization(
            withPurposeKey: purposeKey
        )
        refreshStatus()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        refreshStatus()
    }
}

// 위치 정확도 관리 뷰
struct LocationAccuracyView: View {
    @State private var manager = LocationAccuracyManager()
    @State private var isRequestingAccuracy = false
    
    var body: some View {
        VStack(spacing: 24) {
            // 현재 정확도 상태
            accuracyStatusView
            
            Divider()
            
            // 정확한 위치가 필요한 이유 설명
            if !manager.isPreciseLocationEnabled {
                preciseLocationPrompt
            } else {
                preciseLocationEnabled
            }
        }
        .padding()
    }
    
    private var accuracyStatusView: some View {
        HStack {
            Image(systemName: manager.isPreciseLocationEnabled ? "scope" : "circle.dashed")
                .font(.title)
                .foregroundStyle(manager.isPreciseLocationEnabled ? .green : .orange)
            
            VStack(alignment: .leading) {
                Text(manager.isPreciseLocationEnabled ? "정확한 위치" : "대략적 위치")
                    .font(.headline)
                
                Text(manager.isPreciseLocationEnabled
                     ? "정확한 위치 정보를 사용 중입니다"
                     : "약 5km 반경 내의 위치만 제공됩니다")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var preciseLocationPrompt: some View {
        VStack(spacing: 16) {
            Image(systemName: "map.fill")
                .font(.system(size: 40))
                .foregroundStyle(.blue.gradient)
            
            Text("정확한 위치가 필요합니다")
                .font(.headline)
            
            Text("내 주변 매장을 정확하게 찾으려면\n정확한 위치 접근이 필요합니다.")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button("정확한 위치 허용") {
                Task {
                    isRequestingAccuracy = true
                    // Info.plist에 NSLocationTemporaryUsageDescriptionDictionary 필요
                    try? await manager.requestTemporaryFullAccuracy(purposeKey: "NearbyStores")
                    isRequestingAccuracy = false
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isRequestingAccuracy)
        }
    }
    
    private var preciseLocationEnabled: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(.green)
            
            Text("정확한 위치를 사용 중입니다")
                .font(.headline)
        }
    }
}

// iOS 26 PermissionKit - HIG Lab
#endif
