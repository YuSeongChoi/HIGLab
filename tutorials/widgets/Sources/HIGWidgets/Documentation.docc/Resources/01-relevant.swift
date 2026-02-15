import SwiftUI
import WidgetKit

/// Relevant (시의적절) 원칙을 따르는 위젯
/// 시간대에 따라 다른 정보를 표시
struct RelevantWeatherWidget: View {
    let currentHour: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 현재 시간에 따라 다른 메시지
            Text(timeBasedMessage)
                .font(.headline)

            HStack {
                // 현재 날씨
                VStack(alignment: .leading) {
                    Text("지금")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("24°")
                        .font(.title2.bold())
                }

                Spacer()

                // 다음 시간대 예보
                VStack(alignment: .trailing) {
                    Text(nextTimeLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("22°")
                        .font(.title3.bold())
                }
            }

            // Timeline 표시
            HStack(spacing: 4) {
                ForEach(0..<5) { index in
                    Rectangle()
                        .fill(index <= currentRelevanceIndex ? .blue : .gray.opacity(0.3))
                        .frame(height: 4)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }

    // 시간대별 메시지
    var timeBasedMessage: String {
        switch currentHour {
        case 6..<12:
            return "좋은 아침이에요 ☀️"
        case 12..<18:
            return "오후 날씨 확인"
        case 18..<22:
            return "저녁 기온이 내려가요"
        default:
            return "내일 날씨 준비하세요"
        }
    }

    var nextTimeLabel: String {
        currentHour < 18 ? "오후" : "내일"
    }

    var currentRelevanceIndex: Int {
        min(4, currentHour / 5)
    }
}

#Preview {
    RelevantWeatherWidget(currentHour: 14)
        .previewContext(WidgetPreviewContext(family: .systemMedium))
}
