// 원형 클리핑 & 오버레이

import SwiftUI

struct CircleClippingView: View {
    let image: Image?
    let size: CGFloat
    let showEditBadge: Bool
    
    init(image: Image?, size: CGFloat = 120, showEditBadge: Bool = true) {
        self.image = image
        self.size = size
        self.showEditBadge = showEditBadge
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // 메인 이미지
            if let image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())  // 원형으로 클리핑
                    .overlay {
                        Circle()
                            .stroke(.white, lineWidth: 3)
                    }
                    .shadow(radius: 5)
            } else {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.system(size: size * 0.4))
                            .foregroundStyle(.white)
                    }
            }
            
            // 편집 배지
            if showEditBadge {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: size * 0.25))
                    .foregroundStyle(.white, .blue)
                    .background(Circle().fill(.white).padding(2))
            }
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        CircleClippingView(image: nil, size: 100)
        CircleClippingView(
            image: Image(systemName: "photo.artframe"),
            size: 150
        )
    }
}
