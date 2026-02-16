import SwiftUI
import MapKit

struct ContentView: View {
    var body: some View {
        // 가장 단순한 Map
        // 현재 지역의 지도가 자동으로 표시됨
        Map {
            // 콘텐츠 없이 빈 지도
        }
    }
}

#Preview {
    ContentView()
}
