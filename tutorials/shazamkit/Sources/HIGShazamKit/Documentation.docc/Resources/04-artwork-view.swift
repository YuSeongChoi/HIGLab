import SwiftUI

/// 재사용 가능한 앨범 아트 컴포넌트
struct ArtworkView: View {
    let song: Song
    var size: ArtworkViewSize = .medium
    var showShadow: Bool = true
    
    enum ArtworkViewSize {
        case small, medium, large
        
        var dimension: CGFloat {
            switch self {
            case .small: return 60
            case .medium: return 120
            case .large: return 250
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 12
            case .large: return 20
            }
        }
        
        var imageSize: Int {
            Int(dimension * 2)  // @2x 대응
        }
    }
    
    var body: some View {
        AsyncImage(url: song.artworkURL(width: size.imageSize, height: size.imageSize)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .overlay {
                    Image(systemName: "music.note")
                        .font(.system(size: size.dimension * 0.3))
                        .foregroundStyle(.secondary)
                }
        }
        .frame(width: size.dimension, height: size.dimension)
        .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius))
        .shadow(
            color: showShadow ? .black.opacity(0.2) : .clear,
            radius: showShadow ? 10 : 0,
            y: showShadow ? 5 : 0
        )
    }
}
