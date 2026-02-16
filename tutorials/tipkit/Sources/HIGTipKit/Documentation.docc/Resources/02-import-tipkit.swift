import SwiftUI
import TipKit  // TipKit 프레임워크 import

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("TipKit 데모")
                    .font(.largeTitle)
                
                // 여기에 팁을 추가할 예정
            }
            .navigationTitle("홈")
        }
    }
}

#Preview {
    ContentView()
}
