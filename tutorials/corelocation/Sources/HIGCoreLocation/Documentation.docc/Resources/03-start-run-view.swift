import SwiftUI
import CoreLocation

/// 러닝 시작 화면
struct StartRunView: View {
    @EnvironmentObject var locationManager: LocationManager
    @State private var isLoading = false
    @State private var showRunning = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 지도 영역
                RunMapView()
                    .frame(height: 400)
                
                // 현재 위치 정보
                if let location = locationManager.currentLocation {
                    LocationInfoCard(location: location)
                        .padding()
                } else {
                    LoadingCard()
                        .padding()
                }
                
                Spacer()
                
                // 러닝 시작 버튼
                Button {
                    startRunning()
                } label: {
                    HStack {
                        Image(systemName: "figure.run")
                        Text("러닝 시작")
                    }
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(locationManager.currentLocation != nil ? .green : .gray)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(locationManager.currentLocation == nil)
                .padding()
            }
            .navigationTitle("러닝")
            .onAppear {
                locationManager.requestCurrentLocation()
            }
            .fullScreenCover(isPresented: $showRunning) {
                RunningView()
            }
        }
    }
    
    private func startRunning() {
        showRunning = true
    }
}

/// 현재 위치 정보 카드
struct LocationInfoCard: View {
    let location: CLLocation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundStyle(.blue)
                Text("현재 위치")
                    .font(.headline)
                Spacer()
                Text(location.accuracyLevel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text(String(format: "%.4f, %.4f", 
                       location.coordinate.latitude,
                       location.coordinate.longitude))
                .font(.subheadline.monospaced())
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// 로딩 카드
struct LoadingCard: View {
    var body: some View {
        HStack {
            ProgressView()
            Text("위치 확인 중...")
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// Placeholder
struct RunningView: View {
    var body: some View {
        Text("러닝 중...")
    }
}

#Preview {
    StartRunView()
        .environmentObject(LocationManager())
}
