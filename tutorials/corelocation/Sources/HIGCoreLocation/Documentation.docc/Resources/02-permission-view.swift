import SwiftUI

/// 위치 권한 요청 온보딩 뷰
struct PermissionView: View {
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // 아이콘
            Image(systemName: "location.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            // 제목
            Text("위치 권한이 필요해요")
                .font(.title)
                .bold()
            
            // 설명
            VStack(spacing: 16) {
                FeatureRow(
                    icon: "figure.run",
                    title: "실시간 경로 추적",
                    description: "러닝하는 동안 정확한 경로를 기록합니다."
                )
                
                FeatureRow(
                    icon: "speedometer",
                    title: "페이스 & 거리",
                    description: "현재 페이스와 총 거리를 실시간으로 계산합니다."
                )
                
                FeatureRow(
                    icon: "map",
                    title: "러닝 지도",
                    description: "완료된 러닝을 지도에서 확인할 수 있습니다."
                )
            }
            .padding(.horizontal)
            
            Spacer()
            
            // 권한 요청 버튼
            Button {
                locationManager.requestWhenInUseAuthorization()
            } label: {
                Text("위치 권한 허용하기")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            
            // 나중에 버튼
            Button("나중에 하기") {
                // 온보딩 스킵
            }
            .foregroundStyle(.secondary)
            .padding(.bottom)
        }
    }
}

/// 기능 설명 행
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    PermissionView()
        .environmentObject(LocationManager())
}
