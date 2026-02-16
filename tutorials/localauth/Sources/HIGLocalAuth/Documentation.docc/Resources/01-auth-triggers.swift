import SwiftUI

// 인증을 요청해야 하는 시점들

struct ContentView: View {
    @State private var isUnlocked = false
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        Group {
            if isUnlocked {
                VaultListView()
            } else {
                LockScreenView()
            }
        }
        // 1. 앱 최초 실행 시
        .onAppear {
            requestAuthentication()
        }
        // 2. 백그라운드에서 복귀 시
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active && oldPhase == .background {
                // 설정에 따라 재인증 요구
                if shouldRequireReauth() {
                    isUnlocked = false
                    requestAuthentication()
                }
            }
        }
    }
    
    func requestAuthentication() {
        // 인증 로직
    }
    
    func shouldRequireReauth() -> Bool {
        // 백그라운드 시간 확인
        return true
    }
}

// 3. 민감한 작업 수행 전
func deleteItem(_ item: VaultItem) {
    // 삭제 전 재인증 요구
    authenticateThenDelete(item)
}

func exportData() {
    // 내보내기 전 재인증 요구
    authenticateThenExport()
}
