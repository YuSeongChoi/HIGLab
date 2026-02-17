import SwiftUI
import WidgetKit

struct TimerProgressView: View {
    let startTime: Date
    let endTime: Date
    
    var body: some View {
        VStack(spacing: 8) {
            // 진행률 바
            ProgressView(
                timerInterval: startTime...endTime,
                countsDown: true
            ) {
                // 라벨 (선택적)
                Text("배달 진행 중")
            } currentValueLabel: {
                // 현재 값 라벨 (선택적)
                Text(endTime, style: .timer)
                    .monospacedDigit()
            }
            .progressViewStyle(.linear)
            .tint(.blue)
        }
        .padding()
    }
}

// 잠금 화면에서의 활용
struct LockScreenTimerView: View {
    let context: ActivityViewContext<DeliveryAttributes>
    
    var body: some View {
        let start = Date(timeIntervalSince1970: context.state.orderTime)
        let end = Date(timeIntervalSince1970: context.state.estimatedArrival)
        
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bicycle")
                Text("배달 중")
                    .font(.headline)
                Spacer()
                Text(end, style: .timer)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .monospacedDigit()
            }
            
            ProgressView(
                timerInterval: start...end,
                countsDown: true
            )
            .progressViewStyle(.linear)
            .tint(.green)
        }
    }
}
