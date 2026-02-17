import SwiftUI

// MARK: - 분류 결과 뷰
// 이미지 분류 결과를 리스트로 표시

struct ResultsView: View {
    
    // MARK: - 프로퍼티
    let results: [ClassificationResult]
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 헤더
            Text("분류 결과")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            // 결과 리스트
            ForEach(results) { result in
                ResultRow(result: result)
            }
        }
        .padding()
        .background(.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
                // 라벨
                Text(result.label)
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
                        .fill(confidenceColor)
                        .frame(
                            width: appeared ? geometry.size.width * CGFloat(result.confidence) : 0,
                            height: 8
                        )
                        .animation(.spring(duration: 0.6), value: appeared)
                }
            }
            .frame(height: 8)
        }
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
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("분류 중...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding(32)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - 프리뷰
#Preview("Results View") {
    ResultsView(results: [
        ClassificationResult(label: "golden retriever", confidence: 0.95),
        ClassificationResult(label: "labrador retriever", confidence: 0.72),
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
