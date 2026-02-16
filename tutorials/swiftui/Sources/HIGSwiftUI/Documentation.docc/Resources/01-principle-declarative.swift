import SwiftUI

// 원칙 1: 선언적 구문 (Declarative Syntax)
// "이렇게 생긴 UI가 있어야 한다"고 설명만 합니다.

struct RecipeHeaderExample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // "제목이 있다"
            Text("김치찌개")
                .font(.title)
                .fontWeight(.bold)
            
            // "설명이 있다"
            Text("구수하고 얼큰한 한국의 대표 찌개")
                .foregroundStyle(.secondary)
            
            // "시간 정보가 있다"
            HStack {
                Image(systemName: "clock")
                Text("30분")
            }
            .font(.subheadline)
            .foregroundStyle(.orange)
        }
        .padding()
    }
}

// 복잡한 렌더링 로직? SwiftUI가 처리합니다.
// 우리는 "무엇"만 선언하면 됩니다!

#Preview {
    RecipeHeaderExample()
}
