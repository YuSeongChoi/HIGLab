import SwiftUI

// 원칙 2: 조합 가능성 (Composability)
// 작은 뷰를 조합해서 큰 뷰를 만듭니다 - 레고 블록처럼!

// 작은 조각 1: 별점 표시
struct StarRating: View {
    let rating: Double
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= Int(rating) ? "star.fill" : "star")
                    .foregroundStyle(.yellow)
            }
        }
    }
}

// 작은 조각 2: 난이도 뱃지
struct DifficultyBadge: View {
    let difficulty: String
    
    var body: some View {
        Text(difficulty)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.green.opacity(0.2))
            .clipShape(Capsule())
    }
}

// 조합: 레시피 카드
struct RecipeCard: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("김치찌개")
                .font(.headline)
            
            HStack {
                StarRating(rating: 4.5)  // 조각 1 사용
                Spacer()
                DifficultyBadge(difficulty: "쉬움")  // 조각 2 사용
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    RecipeCard()
        .padding()
}
