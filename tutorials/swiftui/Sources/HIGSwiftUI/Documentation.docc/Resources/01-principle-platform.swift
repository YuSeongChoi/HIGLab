import SwiftUI

// 원칙 4: 크로스 플랫폼 (Cross-Platform)
// 하나의 코드로 여러 플랫폼 지원!

struct RecipeView: View {
    var body: some View {
        // 이 코드는 iOS, macOS, watchOS, tvOS 모두에서 동작합니다!
        VStack {
            Image(systemName: "fork.knife")
                .font(.largeTitle)
            
            Text("오늘의 레시피")
                .font(.headline)
            
            Text("김치찌개")
                .font(.title)
        }
    }
}

// 플랫폼별 최적화가 필요하다면?
struct AdaptiveRecipeView: View {
    var body: some View {
        #if os(iOS)
        // iPhone/iPad 전용 UI
        NavigationStack {
            RecipeView()
                .navigationTitle("ChefBook")
        }
        #elseif os(macOS)
        // Mac 전용 UI
        RecipeView()
            .frame(minWidth: 400, minHeight: 300)
        #elseif os(watchOS)
        // Apple Watch 전용 UI
        RecipeView()
            .font(.caption)
        #endif
    }
}

#Preview {
    RecipeView()
}
