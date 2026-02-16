import SwiftUI
import TipKit

struct FavoriteTip: Tip {
    var title: Text {
        Text("즐겨찾기 추가")
    }
    
    var message: Text? {
        Text("이 버튼을 탭하면 즐겨찾기에 추가됩니다")
    }
    
    var image: Image? {
        Image(systemName: "heart.fill")
    }
}

struct FavoriteButton: View {
    let favoriteTip = FavoriteTip()
    @State private var isFavorite = false
    
    var body: some View {
        Button {
            isFavorite.toggle()
            // 기능 사용 시 팁 무효화
            favoriteTip.invalidate(reason: .actionPerformed)
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.title2)
        }
        // popoverTip으로 말풍선 팁 표시
        .popoverTip(favoriteTip)
    }
}
