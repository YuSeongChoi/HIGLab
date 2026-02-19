#if canImport(ImagePlayground)
import SwiftUI
import ImagePlayground

struct ConditionalUIView: View {
    @Environment(\.supportsImagePlayground) private var supportsImagePlayground
    @State private var showPlayground = false
    @State private var showPhotosPicker = false
    
    var body: some View {
        VStack(spacing: 20) {
            if supportsImagePlayground {
                // ImagePlayground 버튼
                Button {
                    showPlayground = true
                } label: {
                    Label("AI로 이미지 생성", systemImage: "wand.and.stars")
                }
                .buttonStyle(.borderedProminent)
                .imagePlaygroundSheet(isPresented: $showPlayground) { url in
                    // 생성된 이미지 처리
                }
            } else {
                // 대체 기능: 사진 선택
                Button {
                    showPhotosPicker = true
                } label: {
                    Label("사진에서 선택", systemImage: "photo.on.rectangle")
                }
                .buttonStyle(.bordered)
                
                Text("AI 이미지 생성은 지원되는 기기에서만 사용 가능합니다")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
#endif
