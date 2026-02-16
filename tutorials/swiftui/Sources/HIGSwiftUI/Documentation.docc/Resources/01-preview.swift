import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.orange)
            
            Text("ChefBook")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("나만의 레시피를 저장하세요")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // 시작 버튼 추가
            Button("시작하기") {
                // 나중에 구현
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
    }
}

// #Preview 매크로로 실시간 미리보기!
// Xcode 우측 Canvas에서 바로 확인할 수 있습니다.
#Preview {
    ContentView()
}

// 여러 프리뷰를 만들 수도 있습니다
#Preview("다크 모드") {
    ContentView()
        .preferredColorScheme(.dark)
}

#Preview("큰 텍스트") {
    ContentView()
        .environment(\.dynamicTypeSize, .xxxLarge)
}
