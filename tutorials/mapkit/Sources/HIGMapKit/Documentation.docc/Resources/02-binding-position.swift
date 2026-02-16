import SwiftUI
import MapKit

struct MapConfigView: View {
    @State private var position: MapCameraPosition = .automatic
    
    var body: some View {
        VStack {
            Map(position: $position) {
                // 콘텐츠
            }
            
            HStack {
                Button("강남") {
                    // 버튼 탭 시 강남으로 이동
                    withAnimation(.easeInOut(duration: 1.0)) {
                        position = .region(MKCoordinateRegion(
                            center: .gangnam,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        ))
                    }
                }
                
                Button("홍대") {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        position = .region(MKCoordinateRegion(
                            center: .hongdae,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        ))
                    }
                }
            }
            .buttonStyle(.bordered)
        }
    }
}
