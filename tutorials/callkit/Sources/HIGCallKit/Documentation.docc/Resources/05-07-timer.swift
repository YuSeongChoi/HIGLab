import SwiftUI
import Combine

struct CallTimerView: View {
    let connectedAt: Date?
    @State private var elapsed: TimeInterval = 0
    @State private var timer: Timer?
    
    var body: some View {
        Text(formattedTime)
            .font(.title2.monospacedDigit())
            .foregroundStyle(.white)
            .onAppear { startTimer() }
            .onDisappear { stopTimer() }
    }
    
    private var formattedTime: String {
        let minutes = Int(elapsed) / 60
        let seconds = Int(elapsed) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func startTimer() {
        guard connectedAt != nil else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if let start = connectedAt {
                elapsed = Date().timeIntervalSince(start)
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
