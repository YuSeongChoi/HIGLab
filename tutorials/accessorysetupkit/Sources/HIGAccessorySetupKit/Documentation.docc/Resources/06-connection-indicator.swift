import SwiftUI

struct ConnectionIndicator: View {
    let state: ConnectionMonitor.ConnectionState
    let signalStrength: Int?
    
    var body: some View {
        HStack(spacing: 8) {
            // 연결 상태 아이콘
            Image(systemName: state.icon)
                .foregroundStyle(stateColor)
                .symbolEffect(.pulse, isActive: state == .connecting || state == .reconnecting)
            
            // 신호 강도 바
            if state == .connected, let rssi = signalStrength {
                SignalBars(rssi: rssi)
            }
            
            // 상태 텍스트
            Text(stateText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: Capsule())
    }
    
    private var stateColor: Color {
        switch state {
        case .connected: return .green
        case .connecting, .reconnecting: return .orange
        case .disconnected: return .red
        }
    }
    
    private var stateText: String {
        switch state {
        case .connected: return "연결됨"
        case .connecting: return "연결 중..."
        case .reconnecting: return "재연결 중..."
        case .disconnected: return "연결 끊김"
        }
    }
}

struct SignalBars: View {
    let rssi: Int
    
    var bars: Int {
        switch rssi {
        case -50...0: return 4
        case -60 ..< -50: return 3
        case -70 ..< -60: return 2
        default: return 1
        }
    }
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...4, id: \.self) { bar in
                RoundedRectangle(cornerRadius: 1)
                    .fill(bar <= bars ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 3, height: CGFloat(bar * 3 + 3))
            }
        }
    }
}
