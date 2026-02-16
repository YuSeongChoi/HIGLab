import SwiftUI

struct Recipe: Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var cookingTime: Int
    var difficulty: String
    var isFavorite: Bool
}

struct RecipeHeaderView: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(recipe.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                // 즐겨찾기 아이콘
                if recipe.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                }
            }
            
            Text(recipe.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                    Text("\(recipe.cookingTime)분")
                }
                .foregroundStyle(.orange)
                
                Text(recipe.difficulty)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.green.opacity(0.2))
                    .foregroundStyle(.green)
                    .clipShape(Capsule())
            }
            .font(.subheadline)
        }
        .padding()
    }
}

// 다양한 프리뷰로 테스트!
#Preview("기본") {
    RecipeHeaderView(
        recipe: Recipe(
            name: "김치찌개",
            description: "구수하고 얼큰한 한국의 대표 찌개",
            cookingTime: 30,
            difficulty: "쉬움",
            isFavorite: true
        )
    )
}

#Preview("긴 제목") {
    RecipeHeaderView(
        recipe: Recipe(
            name: "할머니가 해주시던 된장찌개 레시피",
            description: "구수한 된장과 신선한 야채가 어우러진 건강식",
            cookingTime: 45,
            difficulty: "보통",
            isFavorite: false
        )
    )
}

#Preview("다크모드") {
    RecipeHeaderView(
        recipe: Recipe(
            name: "파스타",
            description: "간단하고 맛있는 알리오 올리오",
            cookingTime: 20,
            difficulty: "쉬움",
            isFavorite: true
        )
    )
    .preferredColorScheme(.dark)
}
