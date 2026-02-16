import SwiftUI

/// CartFlow - Observation으로 만드는 쇼핑 카트 앱
/// 
/// 이 튜토리얼 시리즈에서 함께 만들어갈 앱입니다.
/// 각 챕터마다 새로운 Observation 기능을 추가해봅시다!
@main
struct CartFlowApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            Text("CartFlow 🛒")
                .font(.largeTitle)
                .navigationTitle("홈")
        }
    }
}

#Preview {
    ContentView()
}
