import SwiftUI

struct StateBasedView: View {
    // @State를 붙이면 이 값이 바뀔 때 UI가 자동 업데이트!
    @State private var tapCount = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("탭 횟수: \(tapCount)")
                .font(.largeTitle)
            
            Button("탭하세요!") {
                // 값만 바꾸면 됩니다.
                // reloadData()? setNeedsLayout()? 필요 없습니다!
                tapCount += 1
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

// SwiftUI의 마법: 
// tapCount가 바뀌면 body가 다시 호출되고
// 변경된 부분만 효율적으로 업데이트됩니다!

#Preview {
    StateBasedView()
}
