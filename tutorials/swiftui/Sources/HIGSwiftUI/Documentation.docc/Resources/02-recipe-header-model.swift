import SwiftUI

// 데이터 모델 (간소화)
struct Recipe: Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var cookingTime: Int
    var difficulty: String
}

struct RecipeHeaderView: View {
    // 레시피 데이터를 받습니다
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 실제 데이터 바인딩
            Text(recipe.name)
                .font(.title)
            
            Text(recipe.description)
            
            HStack {
                Image(systemName: "clock")
                Text("\(recipe.cookingTime)분")
            }
            
            Text(recipe.difficulty)
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
