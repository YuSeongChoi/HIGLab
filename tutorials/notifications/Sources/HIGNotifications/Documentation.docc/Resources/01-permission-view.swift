import SwiftUI

struct PermissionRequestView: View {
    @State private var notificationManager = NotificationManager.shared
    @State private var permissionGranted = false
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            Text("알림 권한이 필요합니다")
                .font(.title2.bold())
            
            Text("리마인더를 놓치지 않도록 알림을 보내드릴게요. 언제든 설정에서 변경할 수 있어요.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            Button("알림 허용하기") {
                Task {
                    permissionGranted = await notificationManager.requestAuthorization()
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}
