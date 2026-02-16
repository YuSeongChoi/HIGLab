import SwiftUI
import MapKit

// MARK: - 지도 뷰

/// iOS 17+ MapKit API를 사용한 지도 뷰
/// Markers와 Annotations을 활용한 장소 표시
struct MapView: View {
    
    // MARK: - Properties
    
    /// 표시할 장소 목록
    let places: [Place]
    
    /// 선택된 장소 (바인딩)
    @Binding var selectedPlace: Place?
    
    /// 카메라 위치
    @Binding var cameraPosition: MapCameraPosition
    
    // MARK: - Environment
    
    @Environment(LocationManager.self) private var locationManager
    
    // MARK: - State
    
    /// 선택된 마커 (Map selection용)
    @State private var selectedMarker: Place?
    
    /// 지도 스타일
    @State private var mapStyle: MapStyle = .standard(
        elevation: .realistic,
        pointsOfInterest: .excludingAll
    )
    
    // MARK: - Body
    
    var body: some View {
        Map(
            position: $cameraPosition,
            selection: $selectedMarker
        ) {
            // 사용자 현재 위치
            UserAnnotation()
            
            // 장소 마커들
            ForEach(places) { place in
                // Marker 사용 (iOS 17+)
                Marker(
                    place.name,
                    systemImage: place.category.symbol,
                    coordinate: place.coordinate
                )
                .tint(Color(place.category.color))
                .tag(place)
            }
            
            // 선택된 장소에 Annotation 표시
            if let selected = selectedMarker {
                Annotation(
                    selected.name,
                    coordinate: selected.coordinate,
                    anchor: .bottom
                ) {
                    selectedPlaceAnnotation(for: selected)
                }
            }
        }
        .mapStyle(mapStyle)
        .mapControls {
            // 나침반 (회전 시에만 표시)
            MapCompass()
            
            // 축척 표시
            MapScaleView()
            
            // 피치 컨트롤 (3D)
            MapPitchToggle()
        }
        .onChange(of: selectedMarker) { _, newValue in
            // 마커 선택 시 상세보기 표시
            if let place = newValue {
                selectedPlace = place
            }
        }
        .safeAreaInset(edge: .top) {
            // 지도 스타일 변경 버튼
            mapStylePicker
                .padding(.top, 8)
        }
    }
    
    // MARK: - Subviews
    
    /// 선택된 장소 커스텀 Annotation
    private func selectedPlaceAnnotation(for place: Place) -> some View {
        VStack(spacing: 0) {
            // 말풍선
            VStack(spacing: 4) {
                Text(place.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                if let rating = place.rating {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                        Text(String(format: "%.1f", rating))
                            .font(.caption2)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThickMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 4)
            
            // 삼각형 포인터
            Triangle()
                .fill(.ultraThickMaterial)
                .frame(width: 16, height: 8)
                .shadow(radius: 2)
        }
    }
    
    /// 지도 스타일 선택 피커
    private var mapStylePicker: some View {
        HStack {
            Spacer()
            
            Menu {
                Button {
                    mapStyle = .standard(elevation: .realistic, pointsOfInterest: .excludingAll)
                } label: {
                    Label("기본", systemImage: "map")
                }
                
                Button {
                    mapStyle = .imagery(elevation: .realistic)
                } label: {
                    Label("위성", systemImage: "globe.asia.australia")
                }
                
                Button {
                    mapStyle = .hybrid(elevation: .realistic, pointsOfInterest: .excludingAll)
                } label: {
                    Label("하이브리드", systemImage: "square.stack.3d.up")
                }
            } label: {
                Image(systemName: "map")
                    .font(.body)
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .padding(.trailing)
        }
    }
}

// MARK: - 삼각형 Shape

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview

#Preview {
    MapView(
        places: Place.previews,
        selectedPlace: .constant(nil),
        cameraPosition: .constant(.automatic)
    )
    .environment(LocationManager())
}
