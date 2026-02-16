import GroupActivities
import SwiftUI

// ============================================
// SharePlay 시작 UI
// ============================================

// iOS 17+: ShareLink 사용
struct ModernSharePlayButton: View {
    let activity: WatchTogetherActivity
    
    var body: some View {
        ShareLink(
            item: activity,
            preview: SharePreview(
                activity.movie.title,
                image: Image(systemName: "film")
            )
        ) {
            Label("SharePlay", systemImage: "shareplay")
                .font(.headline)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(Capsule())
        }
    }
}

// 커스텀 버튼 (더 많은 제어 필요할 때)
struct CustomSharePlayButton: View {
    let movie: Movie
    @State private var isLoading = false
    @State private var showError = false
    
    var body: some View {
        Button {
            startSharePlay()
        } label: {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                } else {
                    Image(systemName: "shareplay")
                }
                Text("함께 보기")
            }
            .font(.headline)
            .padding()
            .background(isLoading ? .gray : .blue)
            .foregroundStyle(.white)
            .clipShape(Capsule())
        }
        .disabled(isLoading)
        .alert("SharePlay 오류", isPresented: $showError) {
            Button("확인") { }
        } message: {
            Text("FaceTime 통화 중에만 SharePlay를 사용할 수 있습니다.")
        }
    }
    
    private func startSharePlay() {
        isLoading = true
        
        Task {
            let activity = WatchTogetherActivity(movie: movie)
            
            do {
                _ = try await activity.activate()
            } catch {
                await MainActor.run {
                    showError = true
                }
            }
            
            await MainActor.run {
                isLoading = false
            }
        }
    }
}
