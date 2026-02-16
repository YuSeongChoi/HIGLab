import GroupActivities
import SwiftUI

// ============================================
// Activity 활성화 (SharePlay 시작)
// ============================================

class MovieDetailViewModel: ObservableObject {
    let movie: Movie
    @Published var activationError: Error?
    
    init(movie: Movie) {
        self.movie = movie
    }
    
    // SharePlay 시작
    func startSharePlay() async {
        let activity = WatchTogetherActivity(movie: movie)
        
        do {
            // activate()로 활동 시작
            // FaceTime 통화 중이거나 메시지 SharePlay 세션이 있어야 성공
            let result = try await activity.activate()
            
            // 결과 확인
            if result {
                print("✅ SharePlay 활성화 성공!")
            }
        } catch {
            // 활성화 실패 (FaceTime 없음, 취소됨 등)
            print("❌ SharePlay 활성화 실패: \(error)")
            await MainActor.run {
                self.activationError = error
            }
        }
    }
}

// SwiftUI 버튼 예시
struct SharePlayButton: View {
    @ObservedObject var viewModel: MovieDetailViewModel
    
    var body: some View {
        Button {
            Task {
                await viewModel.startSharePlay()
            }
        } label: {
            Label("SharePlay", systemImage: "shareplay")
        }
    }
}
