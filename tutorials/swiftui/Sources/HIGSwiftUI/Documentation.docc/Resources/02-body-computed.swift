import SwiftUI

struct BodyComputedExample: View {
    @State private var showDetails = false
    
    // body는 computed property입니다.
    // 상태가 바뀔 때마다 다시 호출됩니다.
    var body: some View {
        VStack {
            Text("ChefBook")
                .font(.title)
            
            Button("상세 정보 \(showDetails ? "숨기기" : "보기")") {
                showDetails.toggle()
            }
            
            // showDetails가 바뀌면 body가 다시 계산됩니다!
            if showDetails {
                Text("SwiftUI로 만드는 레시피 앱입니다.")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}

// body는 stored property가 아닙니다:
// ❌ var body: some View = Text("Hello")  // 이렇게 하면 안 됩니다!
// ✅ var body: some View { Text("Hello") }  // 올바른 방법!

#Preview {
    BodyComputedExample()
}
