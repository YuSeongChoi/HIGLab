import SwiftUI

// 커스텀 컨테이너에 @ViewBuilder 활용하기
// ChefBook의 "섹션 카드" 컴포넌트

struct SectionCard<Content: View>: View {
    let title: String
    let systemImage: String
    
    // @ViewBuilder로 클로저를 받습니다
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 헤더
            HStack {
                Image(systemName: systemImage)
                    .foregroundStyle(.orange)
                Text(title)
                    .font(.headline)
            }
            
            Divider()
            
            // 외부에서 전달받은 컨텐츠
            content()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// 사용 예시
struct SectionCardExample: View {
    var body: some View {
        VStack(spacing: 16) {
            // SectionCard 안에 여러 뷰를 자유롭게 배치!
            SectionCard(title: "재료", systemImage: "cart.fill") {
                Text("돼지고기 150g")
                Text("김치 200g")
                Text("두부 1/2모")
            }
            
            SectionCard(title: "조리 시간", systemImage: "clock.fill") {
                HStack {
                    Text("30분")
                        .font(.title)
                    Spacer()
                    Text("쉬움")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(.green.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
    }
}

#Preview {
    SectionCardExample()
}
