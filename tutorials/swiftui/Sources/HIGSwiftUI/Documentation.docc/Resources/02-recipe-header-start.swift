import SwiftUI

// ChefBook: 레시피 헤더 만들기 - 시작

struct RecipeHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 레시피 이름 (큰 폰트)
            Text("레시피 이름")
                .font(.title)
            
            // 설명 (서브텍스트)
            Text("레시피 설명이 여기에 들어갑니다")
            
            // 조리시간
            HStack {
                Image(systemName: "clock")
                Text("30분")
            }
            
            // 난이도 뱃지
            Text("쉬움")
        }
        .padding()
    }
}

#Preview {
    RecipeHeaderView()
}
