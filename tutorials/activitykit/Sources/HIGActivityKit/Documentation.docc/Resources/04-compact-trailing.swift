import SwiftUI

// MARK: - Compact Trailing View
// Dynamic Island 우측 영역 - 예상 도착 시간

struct CompactTrailingView: View {
    let estimatedArrival: Date
    
    var body: some View {
        // 카운트다운 타이머 스타일
        Text(estimatedArrival, style: .timer)
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(.primary)
    }
}

// 분 단위로 표시하고 싶다면:
struct MinutesRemainingView: View {
    let estimatedArrival: Date
    
    var minutesRemaining: Int {
        max(0, Int(estimatedArrival.timeIntervalSinceNow / 60))
    }
    
    var body: some View {
        Text("\(minutesRemaining)분")
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .monospacedDigit()
    }
}
