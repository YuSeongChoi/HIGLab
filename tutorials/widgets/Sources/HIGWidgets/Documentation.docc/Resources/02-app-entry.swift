import SwiftUI

@main
struct WeatherWidgetApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 60))
                .symbolRenderingMode(.multicolor)
            
            Text("날씨 위젯 앱")
                .font(.title)
                .fontWeight(.bold)
            
            Text("홈 화면에서 위젯을 추가하세요")
                .foregroundStyle(.secondary)
        }
    }
}
