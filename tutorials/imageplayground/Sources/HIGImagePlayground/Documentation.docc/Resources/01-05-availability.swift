#if canImport(ImagePlayground)
import SwiftUI
import ImagePlayground

struct AvailabilityCheckView: View {
    // 환경 변수로 ImagePlayground 가용성 확인
    @Environment(\.supportsImagePlayground) private var supportsImagePlayground
    
    var body: some View {
        VStack {
            if supportsImagePlayground {
                // ImagePlayground 사용 가능
                Text("✅ Image Playground를 사용할 수 있습니다")
                    .foregroundStyle(.green)
            } else {
                // 사용 불가능 - 대체 UI 제공
                Text("⚠️ 이 기기에서는 Image Playground를 사용할 수 없습니다")
                    .foregroundStyle(.orange)
                
                Text("Apple Silicon 기기와 iOS 18 이상이 필요합니다")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}
#endif
