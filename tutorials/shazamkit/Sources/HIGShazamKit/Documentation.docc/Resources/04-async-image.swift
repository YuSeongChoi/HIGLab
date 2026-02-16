import SwiftUI

/// AsyncImage로 앨범 아트 표시
struct AlbumArtView: View {
    let url: URL?
    let size: CGFloat
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                // 로딩 중
                ProgressView()
                    .frame(width: size, height: size)
                
            case .success(let image):
                // 성공
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
            case .failure:
                // 실패 - 기본 이미지
                placeholderImage
                
            @unknown default:
                placeholderImage
            }
        }
    }
    
    private var placeholderImage: some View {
        Image(systemName: "music.note")
            .font(.system(size: size * 0.4))
            .foregroundStyle(.secondary)
            .frame(width: size, height: size)
            .background(Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
