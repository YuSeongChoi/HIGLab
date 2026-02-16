import Observation
import SwiftUI

/// ⚠️ 주의: 외부 데이터에 의존하는 계산 프로퍼티
@Observable
class TimeSensitiveStore {
    var eventDate: Date = Date().addingTimeInterval(3600) // 1시간 후
    
    // ❌ 문제: Date()는 @Observable 프로퍼티가 아님!
    // 시간이 지나도 이 값이 자동으로 바뀌지 않습니다.
    var timeRemaining: String {
        let remaining = eventDate.timeIntervalSince(Date())
        if remaining <= 0 {
            return "이벤트 종료"
        }
        let minutes = Int(remaining / 60)
        return "\(minutes)분 남음"
    }
}

// ✅ 해결책 1: Timer를 사용해 수동으로 업데이트
@Observable
class BetterTimeSensitiveStore {
    var eventDate: Date = Date().addingTimeInterval(3600)
    var currentTime: Date = Date() // 이것을 Timer로 업데이트
    
    var timeRemaining: String {
        let remaining = eventDate.timeIntervalSince(currentTime)
        if remaining <= 0 {
            return "이벤트 종료"
        }
        let minutes = Int(remaining / 60)
        return "\(minutes)분 남음"
    }
}

struct CountdownView: View {
    var store: BetterTimeSensitiveStore
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text(store.timeRemaining)
            .onReceive(timer) { _ in
                store.currentTime = Date() // 트리거!
            }
    }
}

// ✅ 해결책 2: TimelineView 사용 (iOS 15+)
struct TimelineCountdownView: View {
    var eventDate: Date
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            let remaining = eventDate.timeIntervalSince(context.date)
            Text("\(Int(remaining / 60))분 남음")
        }
    }
}
