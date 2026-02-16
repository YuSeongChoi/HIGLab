import SwiftUI
import HealthKit

// MARK: - 권한 상태에 따른 UI 피드백

struct HealthAuthorizationView: View {
    @EnvironmentObject var healthManager: HealthManager
    
    var body: some View {
        VStack(spacing: 24) {
            // 권한 필요성 설명
            Image(systemName: "heart.text.square")
                .font(.system(size: 60))
                .foregroundStyle(.pink)
            
            Text("건강 데이터 접근")
                .font(.title.bold())
            
            Text("피트니스 대시보드에 걸음 수, 심박수, 수면 데이터를 표시하려면 건강 앱 접근 권한이 필요합니다.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            Button("권한 설정하기") {
                Task {
                    await healthManager.requestAuthorization()
                }
            }
            .buttonStyle(.borderedProminent)
            
            // 설정 앱으로 이동 안내
            Button("설정에서 변경하기") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.footnote)
        }
        .padding()
    }
}

// 데이터 없음 상태 표시 (권한 거부와 구분 불가)
struct NoDataView: View {
    var body: some View {
        ContentUnavailableView(
            "데이터 없음",
            systemImage: "heart.slash",
            description: Text("건강 데이터가 없거나 접근 권한이 없습니다.\n설정 > 건강 > 데이터 접근 및 기기에서 확인해주세요.")
        )
    }
}
