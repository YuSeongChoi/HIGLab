import SwiftUI
import MapKit

struct MarkerView: View {
    let restaurants = Restaurant.samples
    
    var body: some View {
        Map {
            // ForEach로 여러 마커 생성
            ForEach(restaurants) { restaurant in
                Marker(
                    restaurant.name,
                    systemImage: restaurant.category.icon,
                    coordinate: restaurant.coordinate
                )
                .tint(restaurant.category.color)
            }
        }
    }
}

extension Restaurant.Category {
    /// 카테고리별 SF Symbol 아이콘
    var icon: String {
        switch self {
        case .korean: return "fork.knife"
        case .japanese: return "fish.fill"
        case .chinese: return "takeoutbag.and.cup.and.straw.fill"
        case .western: return "fork.knife.circle.fill"
        case .cafe: return "cup.and.saucer.fill"
        case .bar: return "wineglass.fill"
        }
    }
    
    /// 카테고리별 마커 색상
    var color: Color {
        switch self {
        case .korean: return .red
        case .japanese: return .orange
        case .chinese: return .yellow
        case .western: return .green
        case .cafe: return .brown
        case .bar: return .purple
        }
    }
}
