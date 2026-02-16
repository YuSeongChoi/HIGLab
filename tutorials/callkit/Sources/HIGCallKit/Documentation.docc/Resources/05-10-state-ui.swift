import SwiftUI

struct CallStateView: View {
    let state: CallState
    
    var body: some View {
        VStack(spacing: 8) {
            switch state {
            case .connecting:
                connectingView
                
            case .ringing:
                ringingView
                
            case .connected(let startTime):
                CallTimerView(connectedAt: startTime)
                
            case .onHold:
                holdView
                
            case .ended(let reason):
                endedView(reason: reason)
                
            case .idle:
                EmptyView()
            }
        }
    }
    
    private var connectingView: some View {
        HStack(spacing: 8) {
            ProgressView()
                .tint(.white)
            Text("연결 중...")
                .foregroundStyle(.white.opacity(0.8))
        }
    }
    
    private var ringingView: some View {
        Text("벨이 울리는 중...")
            .foregroundStyle(.white.opacity(0.8))
    }
    
    private var holdView: some View {
        HStack(spacing: 8) {
            Image(systemName: "pause.circle.fill")
                .foregroundStyle(.yellow)
            Text("보류 중")
                .foregroundStyle(.white)
        }
        .font(.title3)
    }
    
    private func endedView(reason: CallEndReason) -> some View {
        VStack(spacing: 4) {
            Image(systemName: iconForReason(reason))
                .font(.title)
            Text(reason.displayText)
        }
        .foregroundStyle(.white.opacity(0.8))
    }
    
    private func iconForReason(_ reason: CallEndReason) -> String {
        switch reason {
        case .normal: "phone.down"
        case .missed: "phone.arrow.down.left"
        case .declined: "phone.down.circle"
        case .failed: "exclamationmark.circle"
        case .remoteEnded: "phone.down"
        case .busy: "phone.badge.waveform"
        }
    }
}

// CallTimerView와 CallEndReason 참조
struct CallTimerView: View {
    let connectedAt: Date?
    var body: some View { Text("00:00") }
}

enum CallState {
    case idle, connecting, ringing, connected(Date), onHold, ended(CallEndReason)
}

enum CallEndReason {
    case normal, missed, declined, failed, remoteEnded, busy
    var displayText: String { "" }
}
