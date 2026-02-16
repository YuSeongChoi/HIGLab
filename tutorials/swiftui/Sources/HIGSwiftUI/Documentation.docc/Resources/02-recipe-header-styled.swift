import SwiftUI

struct Recipe: Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var cookingTime: Int
    var difficulty: String
}

struct RecipeHeaderView: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 제목 - 굵고 크게
            Text(recipe.name)
                .font(.title)
                .fontWeight(.bold)
            
            // 설명 - 부가 색상
            Text(recipe.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // 정보 행 - 아이콘과 함께
            HStack(spacing: 16) {
                // 조리 시간
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                    Text("\(recipe.cookingTime)분")
                }
                .foregroundStyle(.orange)
                
                // 난이도 뱃지
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

#Preview {
    RecipeHeaderView(
        recipe: Recipe(
            name: "김치찌개",
            description: "구수하고 얼큰한 한국의 대표 찌개",
            cookingTime: 30,
            difficulty: "쉬움"
        )
    )
}
