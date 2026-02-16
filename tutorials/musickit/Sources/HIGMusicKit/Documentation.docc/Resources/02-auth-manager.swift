import MusicKit
import Observation

@Observable
class MusicAuthManager {
    var status: MusicAuthorization.Status = .notDetermined
    var isAuthorized: Bool { status == .authorized }
    
    init() {
        // 초기 상태 로드
        status = MusicAuthorization.currentStatus
    }
    
    func requestAuthorization() async {
        status = await MusicAuthorization.request()
    }
    
    func refreshStatus() {
        status = MusicAuthorization.currentStatus
    }
}

// SwiftUI에서 사용
import SwiftUI

struct MusicAuthExample: View {
    @State private var authManager = MusicAuthManager()
    
    var body: some View {
        Group {
            if authManager.isAuthorized {
                Text("권한 허용됨 ✅")
            } else {
                Button("권한 요청") {
                    Task {
                        await authManager.requestAuthorization()
                    }
                }
            }
        }
    }
}
