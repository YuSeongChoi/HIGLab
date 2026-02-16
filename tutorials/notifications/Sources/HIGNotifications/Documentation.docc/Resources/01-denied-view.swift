import SwiftUI

struct PermissionDeniedView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "bell.slash.fill")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)
            
            Text("알림이 꺼져 있어요")
                .font(.title2.bold())
            
            Text("리마인더 알림을 받으려면 설정에서 알림을 켜주세요.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            Button("설정으로 이동") {
                NotificationManager.shared.openAppSettings()
            }
            .buttonStyle(.bordered)
            
            Button("나중에") {
                // 닫기
            }
            .foregroundStyle(.secondary)
        }
        .padding()
    }
}
