import SwiftUI

struct ElapsedTimeView: View {
    let orderTime: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // .relative: "2분 전" 형식
            HStack {
                Text("주문:")
                Text(orderTime, style: .relative)
            }
            .font(.caption)
            
            // .timer: "02:30" 형식 (경과 시간)
            HStack {
                Text("경과 시간:")
                Text(orderTime, style: .timer)
                    .monospacedDigit()
            }
            .font(.caption)
            
            // .offset: 시간대를 고려한 오프셋
            HStack {
                Text("시간대:")
                Text(orderTime, style: .offset)
            }
            .font(.caption)
        }
    }
}

// 타이머 스타일 비교
// .timer:    "2:05:30" - 경과/남은 시간 (시:분:초)
// .relative: "2분 전"  - 상대적 시간 표현
// .offset:   "+2:00"   - 시간대 오프셋
// .date:     "2월 17일" - 날짜
// .time:     "오후 3:30" - 시간
