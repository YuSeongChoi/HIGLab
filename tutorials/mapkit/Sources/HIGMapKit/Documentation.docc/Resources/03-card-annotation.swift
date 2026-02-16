import SwiftUI
import MapKit

struct AnnotationView: View {
    let restaurant = Restaurant.samples[0]
    
    var body: some View {
        Map {
            // 카드형 Annotation
            Annotation(
                restaurant.name,
                coordinate: restaurant.coordinate,
                anchor: .bottom  // 앵커 포인트: 하단 중앙
            ) {
                RestaurantAnnotationView(restaurant: restaurant)
            }
        }
    }
}

/// 맛집 카드 Annotation 뷰
struct RestaurantAnnotationView: View {
    let restaurant: Restaurant
    
    var body: some View {
        VStack(spacing: 4) {
            // 카드 본체
            VStack(alignment: .leading, spacing: 2) {
                Text(restaurant.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text(String(format: "%.1f", restaurant.rating))
                }
                .font(.caption2)
            }
            .padding(8)
            .background(.white)
            .cornerRadius(8)
            .shadow(radius: 2)
            
            // 하단 삼각형 포인터
            Image(systemName: "triangle.fill")
                .font(.caption2)
                .foregroundStyle(.white)
                .rotationEffect(.degrees(180))
                .offset(y: -5)
        }
    }
}
