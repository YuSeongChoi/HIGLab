#if canImport(ImagePlayground)
import SwiftUI
import ImagePlayground

// 좋은 프롬프트 작성 예시
struct GoodPromptsView: View {
    @State private var isPresented = false
    @State private var selectedPrompt = 0
    
    // 구체적이고 시각적인 프롬프트들
    let goodPrompts: [(description: String, concepts: [ImagePlaygroundConcept])] = [
        (
            "구체적인 색상과 환경",
            [
                .text("보라색 꽃밭에서 춤추는 나비"),
                .text("황금빛 석양 배경"),
                .text("따뜻하고 환상적인 분위기")
            ]
        ),
        (
            "명확한 피사체와 행동",
            [
                .text("빨간 스카프를 두른 시바견"),
                .text("눈 덮인 산 정상에 앉아있는"),
                .text("영웅적인 포즈")
            ]
        ),
        (
            "분위기와 스타일 포함",
            [
                .text("아늑한 서재에서 책 읽는 고양이"),
                .text("벽난로 불빛"),
                .text("빈티지 수채화 느낌")
            ]
        )
    ]
    
    var body: some View {
        VStack {
            Picker("프롬프트 선택", selection: $selectedPrompt) {
                ForEach(0..<goodPrompts.count, id: \.self) { index in
                    Text(goodPrompts[index].description).tag(index)
                }
            }
            
            Button("이미지 생성") {
                isPresented = true
            }
        }
        .imagePlaygroundSheet(
            isPresented: $isPresented,
            concepts: goodPrompts[selectedPrompt].concepts
        ) { _ in }
    }
}
#endif
