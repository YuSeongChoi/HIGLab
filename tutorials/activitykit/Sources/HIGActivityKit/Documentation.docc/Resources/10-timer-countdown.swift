import SwiftUI
import WidgetKit

struct DeliveryTimerView: View {
    let estimatedArrival: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("도착 예정")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            // 자동 카운트다운 타이머
            // 서버 업데이트 없이 실시간으로 감소
            Text(estimatedArrival, style: .timer)
                .font(.title2)
                .fontWeight(.bold)
                .monospacedDigit()
        }
    }
}

// 사용 예시
struct CompactTimerView: View {
    let context: ActivityViewContext<DeliveryAttributes>
    
    var body: some View {
        // Date로 변환하여 타이머 표시
        let arrivalDate = Date(
            timeIntervalSince1970: context.state.estimatedArrival
        )
        
        Text(arrivalDate, style: .timer)
            .font(.caption)
            .monospacedDigit()
    }
}
