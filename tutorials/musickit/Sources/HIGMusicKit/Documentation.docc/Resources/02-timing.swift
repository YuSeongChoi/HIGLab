import SwiftUI
import MusicKit

// 권한 요청 타이밍 베스트 프랙티스

struct SearchView: View {
    @State private var searchText = ""
    @State private var showAuthRequest = false
    
    var body: some View {
        VStack {
            TextField("음악 검색", text: $searchText)
                .textFieldStyle(.roundedBorder)
            
            Button("검색") {
                handleSearch()
            }
        }
        .sheet(isPresented: $showAuthRequest) {
            AuthorizationRequestSheet()
        }
    }
    
    private func handleSearch() {
        // 검색 시도 시점에 권한 확인
        let status = MusicAuthorization.currentStatus
        
        if status == .notDetermined {
            // 첫 검색 시 권한 요청
            showAuthRequest = true
        } else if status == .authorized {
            // 권한이 있으면 검색 진행
            performSearch()
        } else {
            // 권한 없으면 안내
            showPermissionAlert()
        }
    }
    
    private func performSearch() {
        // 검색 로직
    }
    
    private func showPermissionAlert() {
        // 알림 표시
    }
}

struct AuthorizationRequestSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("검색을 위해 Apple Music 접근이 필요합니다")
            
            Button("허용") {
                Task {
                    await MusicAuthorization.request()
                    dismiss()
                }
            }
        }
    }
}
