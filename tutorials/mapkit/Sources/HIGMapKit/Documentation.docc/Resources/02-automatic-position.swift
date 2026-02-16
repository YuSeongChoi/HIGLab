import SwiftUI
import MapKit

struct MapConfigView: View {
    // .automatic: 콘텐츠에 맞춰 자동 조정
    @State private var position: MapCameraPosition = .automatic
    
    var body: some View {
        Map(position: $position) {
            Marker("맛집 1", coordinate: .gangnam)
            Marker("맛집 2", coordinate: .hongdae)
            Marker("맛집 3", coordinate: .itaewon)
            // → 세 마커가 모두 보이도록 자동 줌
        }
    }
}

extension CLLocationCoordinate2D {
    static let gangnam = CLLocationCoordinate2D(latitude: 37.4979, longitude: 127.0276)
    static let hongdae = CLLocationCoordinate2D(latitude: 37.5563, longitude: 126.9220)
    static let itaewon = CLLocationCoordinate2D(latitude: 37.5345, longitude: 126.9945)
}
