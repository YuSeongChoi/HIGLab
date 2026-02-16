import SwiftUI
import MusicKit

struct AuthorizationView: View {
    let onAuthorize: () async -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // 아이콘
            Image(systemName: "music.note.list")
                .font(.system(size: 80))
                .foregroundStyle(.pink.gradient)
            
            // 제목
            VStack(spacing: 8) {
                Text("Apple Music 접근 필요")
                    .font(.title)
                    .bold()
                
                Text("다음 기능을 사용하려면\nApple Music 접근 권한이 필요합니다:")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            
            // 기능 목록
            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(icon: "magnifyingglass", text: "음악 검색")
                FeatureRow(icon: "play.circle", text: "음악 재생")
                FeatureRow(icon: "music.note.house", text: "라이브러리 접근")
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // 권한 요청 버튼
            Button {
                Task { await onAuthorize() }
            } label: {
                Text("계속하기")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(.pink)
            Text(text)
        }
    }
}
