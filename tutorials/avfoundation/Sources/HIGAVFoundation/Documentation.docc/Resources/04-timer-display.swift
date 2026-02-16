import SwiftUI

struct RecordingTimerView: View {
    let duration: TimeInterval
    let isRecording: Bool
    
    var body: some View {
        if isRecording {
            HStack(spacing: 8) {
                // 녹화 인디케이터 (깜빡이는 빨간 점)
                Circle()
                    .fill(Color.red)
                    .frame(width: 10, height: 10)
                    .modifier(BlinkingModifier())
                
                // 녹화 시간
                Text(formattedDuration)
                    .font(.system(.headline, design: .monospaced))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.6))
            .clipShape(Capsule())
        }
    }
    
    private var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Blinking Modifier

struct BlinkingModifier: ViewModifier {
    @State private var isVisible = true
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                    isVisible.toggle()
                }
            }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black
        
        VStack {
            RecordingTimerView(duration: 125, isRecording: true)
            RecordingTimerView(duration: 0, isRecording: false)
        }
    }
}
