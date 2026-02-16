import SwiftUI

// 선언적(Declarative) 방식 - SwiftUI
struct ContentView: View {
    var body: some View {
        Text("Hello, SwiftUI!")
            .font(.system(size: 24, weight: .bold))
            .foregroundStyle(.blue)
    }
}

// 단 4줄! 
// "무엇(What)"이 있어야 하는지만 선언합니다.
// 레이아웃? 시스템이 알아서!
// 업데이트? 시스템이 알아서!

#Preview {
    ContentView()
}
