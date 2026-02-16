import SwiftUI

// some View의 의미: "어떤 구체적인 View 타입"
// Opaque Return Type이라고 합니다.

struct SomeViewExample: View {
    var body: some View {
        // 실제 타입: VStack<TupleView<(Text, Text)>>
        // 하지만 외부에서는 그냥 "View"로만 보입니다
        VStack {
            Text("제목")
            Text("부제목")
        }
    }
}

// 왜 some View를 쓰나요?

// 1. 구체적 타입을 쓰면 너무 복잡합니다:
// var body: VStack<TupleView<(Text, Text)>> { ... }  // 😱

// 2. any View는 성능이 떨어집니다:
// var body: any View { ... }  // 타입 정보 손실

// 3. some View는 타입 정보를 유지하면서 간단합니다:
// var body: some View { ... }  // ✅ 완벽!

// 주의: body는 항상 같은 타입을 반환해야 합니다
struct ConditionalViewExample: View {
    @State private var isHappy = true
    
    var body: some View {
        // ❌ 이렇게 하면 에러!
        // if isHappy { Text("😊") } else { Image(systemName: "star") }
        
        // ✅ Group이나 @ViewBuilder로 감싸야 합니다
        Group {
            if isHappy {
                Text("😊")
            } else {
                Image(systemName: "star")
            }
        }
    }
}

#Preview {
    SomeViewExample()
}
