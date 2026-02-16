import SwiftUI
import MapKit

struct RouteStepsView: View {
    let steps: [RouteStep]
    @State private var currentStepIndex = 0
    
    var body: some View {
        VStack {
            // 현재 단계 카드
            if let currentStep = steps[safe: currentStepIndex] {
                CurrentStepCard(step: currentStep)
            }
            
            // 단계 목록
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                        StepBadge(
                            step: step,
                            isCurrentStep: index == currentStepIndex
                        )
                        .onTapGesture {
                            withAnimation {
                                currentStepIndex = index
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct CurrentStepCard: View {
    let step: RouteStep
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(step.instructions)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(step.formattedDistance)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct StepBadge: View {
    let step: RouteStep
    let isCurrentStep: Bool
    
    var body: some View {
        Text("\(step.index + 1)")
            .font(.caption)
            .fontWeight(.bold)
            .frame(width: 30, height: 30)
            .background(isCurrentStep ? Color.blue : Color.gray.opacity(0.3))
            .foregroundStyle(isCurrentStep ? .white : .primary)
            .clipShape(Circle())
    }
}

// Safe array subscript extension
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
