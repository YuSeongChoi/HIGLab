import SwiftUI

struct IntervalPickerView: View {
    @State private var selectedInterval: RepeatInterval = .hourly
    
    var body: some View {
        Picker("반복 간격", selection: $selectedInterval) {
            ForEach(RepeatInterval.allCases, id: \.self) { interval in
                Text(interval.displayName).tag(interval)
            }
        }
    }
}

enum RepeatInterval: CaseIterable {
    case hourly
    case every2Hours
    case every4Hours
    
    var displayName: String {
        switch self {
        case .hourly: "매 시간"
        case .every2Hours: "2시간마다"
        case .every4Hours: "4시간마다"
        }
    }
    
    var seconds: TimeInterval {
        switch self {
        case .hourly: 60 * 60
        case .every2Hours: 2 * 60 * 60
        case .every4Hours: 4 * 60 * 60
        }
    }
}
