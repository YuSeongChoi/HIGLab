import SwiftUI

struct RecordButton: View {
    let isRecording: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // 외곽 원
                Circle()
                    .stroke(Color.white, lineWidth: 4)
                    .frame(width: 70, height: 70)
                
                // 내부 (녹화 중: 빨간 사각형, 대기: 빨간 원)
                if isRecording {
                    // 녹화 중 - 정지 버튼 (사각형)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.red)
                        .frame(width: 28, height: 28)
                } else {
                    // 대기 - 녹화 버튼 (원)
                    Circle()
                        .fill(Color.red)
                        .frame(width: 54, height: 54)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isRecording)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black
        
        VStack(spacing: 40) {
            RecordButton(isRecording: false) {}
            RecordButton(isRecording: true) {}
        }
    }
}
