import SwiftUI
import CoreLocation

/// 앱의 메인 뷰 - 권한 상태에 따라 다른 화면 표시
struct ContentView: View {
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        Group {
            switch locationManager.authorizationStatus {
            case .notDetermined:
                // 권한 요청 전 → 온보딩 화면
                PermissionView()
                
            case .denied, .restricted:
                // 권한 거부 → 설정 안내 화면
                DeniedView()
                
            case .authorizedWhenInUse, .authorizedAlways:
                // 권한 허용 → 메인 화면
                MainTabView()
                
            @unknown default:
                PermissionView()
            }
        }
    }
}

/// 권한 거부 시 표시되는 뷰
struct DeniedView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "location.slash.circle")
                .font(.system(size: 60))
                .foregroundStyle(.red)
            
            Text("위치 권한이 필요해요")
                .font(.title2)
                .bold()
            
            Text("러닝 경로를 기록하려면\n설정에서 위치 권한을 허용해주세요.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            Button("설정으로 이동") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

/// 메인 탭 뷰
struct MainTabView: View {
    var body: some View {
        TabView {
            StartRunView()
                .tabItem {
                    Label("러닝", systemImage: "figure.run")
                }
            
            HistoryView()
                .tabItem {
                    Label("기록", systemImage: "list.bullet")
                }
            
            SettingsView()
                .tabItem {
                    Label("설정", systemImage: "gearshape")
                }
        }
    }
}

// Placeholder Views
struct StartRunView: View {
    var body: some View {
        Text("러닝 시작")
    }
}

struct HistoryView: View {
    var body: some View {
        Text("러닝 기록")
    }
}

struct SettingsView: View {
    var body: some View {
        Text("설정")
    }
}

#Preview {
    ContentView()
        .environmentObject(LocationManager())
}
