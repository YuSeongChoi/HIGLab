import SwiftUI
import MapKit

// iOS 17의 새로운 Map API
// MapContentBuilder를 사용한 선언적 구성

struct ContentView: View {
    var body: some View {
        Map {
            // MapContentBuilder 내부에 콘텐츠 선언
            Marker("서울역", coordinate: .seoulStation)
            Marker("강남역", coordinate: .gangnamStation)
        }
    }
}

extension CLLocationCoordinate2D {
    static let seoulStation = CLLocationCoordinate2D(
        latitude: 37.5546, longitude: 126.9706
    )
    static let gangnamStation = CLLocationCoordinate2D(
        latitude: 37.4979, longitude: 127.0276
    )
}
