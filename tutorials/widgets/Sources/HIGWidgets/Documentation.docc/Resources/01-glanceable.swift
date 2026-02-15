import SwiftUI
import WidgetKit

/// Glanceable (한눈에 파악) 원칙을 따르는 위젯 뷰
/// 핵심 정보만 간결하게 표시: 기온, 날씨 아이콘, 도시명
struct GlanceableWeatherWidget: View {
    var body: some View {
        VStack(spacing: 8) {
            // 날씨 아이콘 - 시각적으로 즉시 인식 가능
            Image(systemName: "sun.max.fill")
                .font(.system(size: 40))
                .foregroundStyle(.yellow)

            // 현재 기온 - 가장 중요한 정보를 크게
            Text("24°")
                .font(.system(size: 48, weight: .bold))

            // 도시명 - 위치 정보
            Text("서울")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.3), .cyan.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

#Preview {
    GlanceableWeatherWidget()
        .previewContext(WidgetPreviewContext(family: .systemSmall))
}
