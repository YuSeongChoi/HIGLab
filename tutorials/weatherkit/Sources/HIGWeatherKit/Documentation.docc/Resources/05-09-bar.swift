import SwiftUI

// 온도 범위 막대

struct TemperatureBar: View {
    let low: Double
    let high: Double
    let range: ClosedRange<Double>
    
    var body: some View {
        GeometryReader { geometry in
            let totalRange = range.upperBound - range.lowerBound
            let startOffset = (low - range.lowerBound) / totalRange
            let endOffset = (high - range.lowerBound) / totalRange
            
            ZStack(alignment: .leading) {
                // 배경 바
                Capsule()
                    .fill(.tertiary)
                
                // 온도 범위 바
                Capsule()
                    .fill(temperatureGradient)
                    .frame(width: geometry.size.width * (endOffset - startOffset))
                    .offset(x: geometry.size.width * startOffset)
            }
        }
        .frame(height: 6)
    }
    
    private var temperatureGradient: LinearGradient {
        LinearGradient(
            colors: [.blue, .green, .yellow, .orange],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
