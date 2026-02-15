import SwiftUI

// MARK: - Arrival Time Display

struct ArrivalTimeView: View {
    let estimatedArrival: Date
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            // 카운트다운
            Text(estimatedArrival, style: .timer)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
            
            // 도착 예정 시각
            Text("\(estimatedArrival.formatted(date: .omitted, time: .shortened)) 도착 예정")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// 분 단위 카운트다운
struct MinutesCountdownView: View {
    let estimatedArrival: Date
    @State private var minutesRemaining: Int = 0
    
    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 2) {
            Text("\(minutesRemaining)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .contentTransition(.numericText())
            Text("분")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .onAppear { updateMinutes() }
        .onChange(of: estimatedArrival) { updateMinutes() }
    }
    
    func updateMinutes() {
        minutesRemaining = max(0, Int(estimatedArrival.timeIntervalSinceNow / 60))
    }
}
