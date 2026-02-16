import SwiftUI
import ImagePlayground

// 앱 맥락에 맞는 동적 프롬프트 생성
struct DynamicPromptsView: View {
    @State private var isPresented = false
    
    // 사용자 데이터 예시
    let userProfile = UserProfile(
        name: "민수",
        favoriteAnimal: "고양이",
        favoriteColor: "파란색",
        hobby: "독서"
    )
    
    // 사용자 데이터를 기반으로 개인화된 개념 생성
    var personalizedConcepts: [ImagePlaygroundConcept] {
        [
            .text("\(userProfile.favoriteColor) 배경의 \(userProfile.favoriteAnimal)"),
            .text("\(userProfile.hobby)를 즐기는 모습"),
            .text("아늑하고 행복한 분위기")
        ]
    }
    
    var body: some View {
        VStack {
            Text("\(userProfile.name)님만을 위한 이미지")
                .font(.headline)
            
            Text("좋아하는 것들을 바탕으로 만들어요")
                .font(.caption)
            
            Button("나만의 이미지 생성") {
                isPresented = true
            }
        }
        .imagePlaygroundSheet(
            isPresented: $isPresented,
            concepts: personalizedConcepts
        ) { _ in }
    }
}

struct UserProfile {
    let name: String
    let favoriteAnimal: String
    let favoriteColor: String
    let hobby: String
}
