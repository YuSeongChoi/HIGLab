#if canImport(ImagePlayground)
import SwiftUI
import ImagePlayground

struct CompleteBasicView: View {
    @State private var isShowingPlayground = false
    @State private var generatedImageURL: URL?
    
    var body: some View {
        VStack(spacing: 24) {
            // 생성된 이미지 표시 영역
            if let url = generatedImageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(radius: 8)
                    case .failure:
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(.red)
                    case .empty:
                        ProgressView("로딩 중...")
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                // 플레이스홀더
                RoundedRectangle(cornerRadius: 16)
                    .fill(.secondary.opacity(0.2))
                    .frame(height: 200)
                    .overlay {
                        VStack {
                            Image(systemName: "photo.badge.plus")
                                .font(.largeTitle)
                            Text("이미지를 생성해보세요")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }
            }
            
            // 생성 버튼
            Button {
                isShowingPlayground = true
            } label: {
                Label("AI 이미지 생성", systemImage: "wand.and.stars")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
        .imagePlaygroundSheet(isPresented: $isShowingPlayground) { url in
            generatedImageURL = url
        }
    }
}
#endif
