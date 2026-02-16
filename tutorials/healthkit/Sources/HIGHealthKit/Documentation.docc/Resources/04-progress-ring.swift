import SwiftUI

// MARK: - Apple Fitness 스타일 프로그레스 링

struct ProgressRingView: View {
    let progress: Double  // 0.0 ~ 1.0
    let lineWidth: CGFloat = 16
    let color: Color = .green
    
    var body: some View {
        ZStack {
            // 배경 링
            Circle()
                .stroke(
                    color.opacity(0.2),
                    lineWidth: lineWidth
                )
            
            // 프로그레스 링
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
        }
    }
}

// 걸음 수와 함께 표시
struct StepsRingView: View {
    let steps: Int
    let goal: Int = 10000
    
    private var progress: Double {
        min(Double(steps) / Double(goal), 1.0)
    }
    
    var body: some View {
        ZStack {
            ProgressRingView(progress: progress)
            
            VStack {
                Image(systemName: "figure.walk")
                    .font(.title)
                Text("\(steps)")
                    .font(.title.bold())
                Text("/ \(goal)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 150, height: 150)
    }
}
