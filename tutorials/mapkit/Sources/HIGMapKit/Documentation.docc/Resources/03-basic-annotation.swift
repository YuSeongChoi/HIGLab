import SwiftUI
import MapKit

struct AnnotationView: View {
    var body: some View {
        Map {
            // Annotation - 커스텀 SwiftUI 뷰
            Annotation(
                "맛집",
                coordinate: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9910)
            ) {
                // content: 원하는 SwiftUI 뷰
                ZStack {
                    Circle()
                        .fill(.red)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "fork.knife")
                        .foregroundStyle(.white)
                }
            }
        }
    }
}
