import SwiftUI

// MARK: - 걸음 수 카드 View

struct StepsCardView: View {
    let steps: Int
    let goal: Int = 10000
    
    private var progress: Double {
        min(Double(steps) / Double(goal), 1.0)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // 아이콘
            Image(systemName: "figure.walk")
                .font(.system(size: 32))
                .foregroundStyle(.green)
            
            // 걸음 수
            Text("\(steps.formatted())")
                .font(.system(size: 42, weight: .bold, design: .rounded))
            
            Text("걸음")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // 프로그레스 바
            ProgressView(value: progress)
                .tint(.green)
            
            // 목표
            Text("목표: \(goal.formatted())")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    StepsCardView(steps: 7523)
        .padding()
}
