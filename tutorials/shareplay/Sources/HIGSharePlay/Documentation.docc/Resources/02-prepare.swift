import GroupActivities
import SwiftUI

// ============================================
// Activity 활성화 전 준비 상태 확인
// ============================================

class MovieDetailViewModel: ObservableObject {
    let movie: Movie
    @Published var canSharePlay = false
    @Published var needsConfirmation = false
    
    init(movie: Movie) {
        self.movie = movie
    }
    
    // 활성화 전 준비 상태 확인
    func checkSharePlayAvailability() async {
        let activity = WatchTogetherActivity(movie: movie)
        
        switch await activity.prepareForActivation() {
            
        case .activationDisabled:
            // SharePlay 불가능 (FaceTime 없음, 설정에서 비활성화 등)
            print("❌ SharePlay를 사용할 수 없습니다")
            await MainActor.run {
                self.canSharePlay = false
            }
            
        case .activationPreferred:
            // 바로 활성화 가능 (이미 FaceTime 통화 중)
            print("✅ SharePlay 준비 완료! 바로 시작할 수 있습니다")
            await MainActor.run {
                self.canSharePlay = true
                self.needsConfirmation = false
            }
            
        case .cancelled:
            // 사용자가 취소함
            print("⚠️ 사용자가 취소했습니다")
            
        @unknown default:
            break
        }
    }
    
    // 준비 확인 후 활성화
    func startSharePlayWithPreparation() async {
        await checkSharePlayAvailability()
        
        if canSharePlay {
            let activity = WatchTogetherActivity(movie: movie)
            _ = try? await activity.activate()
        }
    }
}
