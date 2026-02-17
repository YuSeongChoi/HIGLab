import SwiftUI

// MARK: - 분류 결과 뷰
// 이미지 분류 결과를 다양한 형태로 표시
// VNClassificationObservation 결과 시각화

struct ResultsView: View {
    
    // MARK: - 프로퍼티
    let results: [ClassificationResult]
    
    // MARK: - 상태
    @State private var displayStyle: ResultDisplayStyle = .list
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 헤더
            HStack {
                Text("분류 결과")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                // 표시 스타일 토글
                Picker("스타일", selection: $displayStyle) {
                    ForEach(ResultDisplayStyle.allCases) { style in
                        Image(systemName: style.iconName).tag(style)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 100)
            }
            
            // 결과 표시
            switch displayStyle {
            case .list:
                listView
            case .chart:
                chartView
            }
        }
        .padding()
        .background(.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - 리스트 뷰
    @ViewBuilder
    private var listView: some View {
        ForEach(results) { result in
            ResultRow(result: result)
        }
    }
    
    // MARK: - 차트 뷰
    @ViewBuilder
    private var chartView: some View {
        VStack(spacing: 8) {
            ForEach(results) { result in
                HStack {
                    Text(result.formattedLabel)
                        .font(.caption)
                        .lineLimit(1)
                        .frame(width: 100, alignment: .leading)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.gray.opacity(0.2))
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(colorFor(result.confidenceLevel))
                                .frame(width: geometry.size.width * CGFloat(result.confidence))
                        }
                    }
                    .frame(height: 20)
                    
                    Text(result.confidencePercentage)
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(width: 50, alignment: .trailing)
                }
            }
        }
    }
    
    private func colorFor(_ level: ConfidenceLevel) -> Color {
        switch level {
        case .high: return .green
        case .medium: return .orange
        case .low: return .yellow
        case .veryLow: return .red
        }
    }
}

/// 결과 표시 스타일
enum ResultDisplayStyle: String, CaseIterable, Identifiable {
    case list = "리스트"
    case chart = "차트"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .list: return "list.bullet"
        case .chart: return "chart.bar"
        }
    }
}

// MARK: - 결과 행
struct ResultRow: View {
    let result: ClassificationResult
    
    // MARK: - 애니메이션 상태
    @State private var appeared = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 라벨과 신뢰도
            HStack {
                // 신뢰도 레벨 아이콘
                Image(systemName: result.confidenceLevel.iconName)
                    .foregroundStyle(confidenceColor)
                
                // 라벨
                Text(result.formattedLabel)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Spacer()
                
                // 신뢰도 퍼센트
                Text(result.confidencePercentage)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(confidenceColor)
            }
            
            // 프로그레스 바
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 배경
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    // 채워진 부분
                    RoundedRectangle(cornerRadius: 4)
                        .fill(confidenceColor.gradient)
                        .frame(
                            width: appeared ? geometry.size.width * CGFloat(result.confidence) : 0,
                            height: 8
                        )
                        .animation(.spring(duration: 0.6), value: appeared)
                }
            }
            .frame(height: 8)
        }
        .padding(.vertical, 4)
        .onAppear {
            appeared = true
        }
    }
    
    // MARK: - 신뢰도 색상
    private var confidenceColor: Color {
        switch result.confidenceLevel {
        case .high:
            return .green
        case .medium:
            return .orange
        case .low:
            return .yellow
        case .veryLow:
            return .red
        }
    }
}

// MARK: - 빈 결과 뷰
struct EmptyResultsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            
            Text("분류 결과가 없습니다")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("이미지를 선택하거나 카메라로 촬영하세요")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - 로딩 뷰
struct ClassificationLoadingView: View {
    let message: String
    
    init(message: String = "분류 중...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text(message)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding(32)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - 컴팩트 결과 뷰
/// 작은 공간에서 결과를 표시할 때 사용
struct CompactResultsView: View {
    let results: [ClassificationResult]
    let maxResults: Int
    
    init(results: [ClassificationResult], maxResults: Int = 3) {
        self.results = results
        self.maxResults = maxResults
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(results.prefix(maxResults).enumerated()), id: \.element.id) { index, result in
                HStack {
                    Text("\(index + 1).")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 20, alignment: .leading)
                    
                    Text(result.formattedLabel)
                        .font(.caption)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(result.confidencePercentage)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(colorFor(result.confidenceLevel))
                }
            }
            
            if results.count > maxResults {
                Text("+\(results.count - maxResults)개 더보기")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }
    
    private func colorFor(_ level: ConfidenceLevel) -> Color {
        switch level {
        case .high: return .green
        case .medium: return .orange
        case .low: return .yellow
        case .veryLow: return .red
        }
    }
}

// MARK: - 상세 결과 뷰
/// 결과를 상세하게 표시 (디버깅용)
struct DetailedResultView: View {
    let result: ClassificationResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 라벨
            Text(result.formattedLabel)
                .font(.title3)
                .fontWeight(.bold)
            
            Divider()
            
            // 상세 정보
            Group {
                LabeledContent("원본 라벨", value: result.label)
                LabeledContent("신뢰도", value: result.confidenceDetailedString)
                LabeledContent("신뢰도 (%)", value: result.confidencePercentage)
                LabeledContent("신뢰도 레벨", value: result.confidenceLevel.rawValue)
                
                if let revision = result.requestRevision {
                    LabeledContent("요청 리비전", value: "\(revision)")
                }
                
                LabeledContent("타임스탬프", value: result.timestamp.formatted())
            }
            .font(.caption)
        }
        .padding()
        .background(.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 프리뷰
#Preview("Results View") {
    ResultsView(results: [
        ClassificationResult(label: "golden_retriever", confidence: 0.95),
        ClassificationResult(label: "labrador_retriever", confidence: 0.72),
        ClassificationResult(label: "dog", confidence: 0.45),
        ClassificationResult(label: "animal", confidence: 0.12)
    ])
    .padding()
}

#Preview("Empty Results") {
    EmptyResultsView()
}

#Preview("Loading") {
    ClassificationLoadingView()
}

#Preview("Compact Results") {
    CompactResultsView(results: [
        ClassificationResult(label: "golden_retriever", confidence: 0.95),
        ClassificationResult(label: "labrador_retriever", confidence: 0.72),
        ClassificationResult(label: "dog", confidence: 0.45)
    ])
    .padding()
}

#Preview("Detailed Result") {
    DetailedResultView(result: ClassificationResult(
        label: "golden_retriever",
        confidence: 0.95,
        requestRevision: 3
    ))
    .padding()
}
