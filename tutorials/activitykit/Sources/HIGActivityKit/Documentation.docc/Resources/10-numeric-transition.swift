import SwiftUI
import WidgetKit

struct NumericTransitionView: View {
    let remainingMinutes: Int
    let remainingStops: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // 남은 시간 - 숫자 전환 애니메이션
            VStack {
                Text("\(remainingMinutes)")
                    .font(.title)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    // 숫자 변경 시 카운트다운 효과
                    .contentTransition(.numericText(countsDown: true))
                Text("분")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
                .frame(height: 40)
            
            // 남은 정류장 - 일반 숫자 전환
            VStack {
                Text("\(remainingStops)")
                    .font(.title)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    // 값이 증가/감소 모두 가능할 때
                    .contentTransition(.numericText())
                Text("정류장")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .animation(.snappy, value: remainingMinutes)
        .animation(.snappy, value: remainingStops)
    }
}

// 가격/포인트 표시에도 활용
struct PointsView: View {
    let earnedPoints: Int
    
    var body: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
            Text("+\(earnedPoints)")
                .font(.headline)
                .contentTransition(.numericText(value: Double(earnedPoints)))
            Text("포인트")
                .font(.caption)
        }
    }
}
