import SwiftUI
import MusicKit

// 사전 설명 화면 패턴
// 시스템 다이얼로그 전에 앱 자체 화면으로 설명하면 승인율이 높아집니다

struct PrePermissionView: View {
    @Binding var showSystemPrompt: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // 앱 아이콘/일러스트
            Image(systemName: "music.mic")
                .font(.system(size: 100))
                .foregroundStyle(.pink.gradient)
            
            // 가치 제안
            VStack(spacing: 8) {
                Text("나만의 플레이리스트를 만들어보세요")
                    .font(.title2)
                    .bold()
                
                Text("Apple Music의 방대한 라이브러리에서\n좋아하는 음악을 찾고 재생할 수 있습니다.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            
            // 기능 하이라이트
            VStack(alignment: .leading, spacing: 16) {
                PermissionFeature(
                    icon: "waveform",
                    title: "1억 곡 이상의 음악",
                    description: "Apple Music 전체 카탈로그 검색"
                )
                PermissionFeature(
                    icon: "heart.fill",
                    title: "개인 맞춤 추천",
                    description: "취향에 맞는 음악 발견"
                )
                PermissionFeature(
                    icon: "music.note.list",
                    title: "내 라이브러리",
                    description: "저장한 음악과 플레이리스트 관리"
                )
            }
            .padding()
            
            Spacer()
            
            // 계속 버튼 (시스템 프롬프트 트리거)
            Button {
                showSystemPrompt = true
            } label: {
                Text("시작하기")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            
            // 나중에 버튼
            Button("나중에") {
                // 권한 없이 제한된 기능 사용
            }
            .foregroundStyle(.secondary)
        }
        .padding()
    }
}

struct PermissionFeature: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 32)
                .foregroundStyle(.pink)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .bold()
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
