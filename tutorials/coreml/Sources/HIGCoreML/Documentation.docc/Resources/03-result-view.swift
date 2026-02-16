import SwiftUI

/// 분류 결과 표시 뷰
struct ClassificationResultView: View {
    let result: ImageClassificationResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 최상위 결과
            topResultView
            
            Divider()
            
            // 상위 5개 결과 바
            resultsBarView
            
            // 분류 시간
            if result.classificationTime > 0 {
                Text("분류 시간: \(String(format: "%.0fms", result.classificationTime * 1000))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - 최상위 결과
    @ViewBuilder
    private var topResultView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(result.topLabel)
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(2)
                
                HStack(spacing: 4) {
                    Image(systemName: result.isValid ? "checkmark.circle.fill" : "questionmark.circle.fill")
                        .foregroundStyle(result.isValid ? .green : .orange)
                    
                    Text(result.confidenceText)
                        .font(.headline)
                        .foregroundStyle(result.isValid ? .green : .orange)
                }
            }
            
            Spacer()
            
            // 신뢰도 게이지
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                
                Circle()
                    .trim(from: 0, to: CGFloat(result.topConfidence))
                    .stroke(
                        result.isValid ? Color.green : Color.orange,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                
                Text(result.confidenceText)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .frame(width: 60, height: 60)
        }
    }
    
    // MARK: - 상위 결과 바
    @ViewBuilder
    private var resultsBarView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("상위 결과")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            ForEach(result.topResults) { classification in
                HStack {
                    Text(classification.label)
                        .font(.subheadline)
                        .lineLimit(1)
                        .frame(maxWidth: 150, alignment: .leading)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                                .clipShape(Capsule())
                            
                            Rectangle()
                                .fill(barColor(for: classification.confidence))
                                .frame(
                                    width: geometry.size.width * classification.progress,
                                    height: 8
                                )
                                .clipShape(Capsule())
                        }
                    }
                    .frame(height: 8)
                    
                    Text(classification.confidenceText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .trailing)
                }
            }
        }
    }
    
    private func barColor(for confidence: Float) -> Color {
        switch confidence {
        case 0.8...: return .green
        case 0.5..<0.8: return .blue
        case 0.2..<0.5: return .orange
        default: return .gray
        }
    }
}

#Preview {
    ClassificationResultView(result: .preview)
        .padding()
}
