import SwiftUI

// SecureVault 앱 구조

// 1. 잠금 화면 - 인증 요청
struct LockScreenView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "lock.shield")
                .font(.system(size: 64))
            Text("SecureVault")
                .font(.title)
            Button("잠금 해제") {
                // 인증 요청
            }
        }
    }
}

// 2. 금고 목록 - 보호된 아이템들
struct VaultListView: View {
    var body: some View {
        List {
            Text("비밀 메모 1")
            Text("중요 문서")
            Text("API 키")
        }
        .navigationTitle("내 금고")
    }
}

// 3. 아이템 상세 - 민감한 정보
struct VaultItemDetailView: View {
    let item: VaultItem
    
    var body: some View {
        Text(item.content)
            .padding()
    }
}

struct VaultItem: Identifiable {
    let id = UUID()
    let title: String
    let content: String
}
