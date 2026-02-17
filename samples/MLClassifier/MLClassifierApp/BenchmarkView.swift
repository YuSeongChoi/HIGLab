import SwiftUI

// MARK: - 벤치마크 뷰
// CoreML 모델 성능 측정 및 비교를 위한 뷰
// MLModel, MLComputeUnits, MLPredictionOptions 활용

struct BenchmarkView: View {
    
    // MARK: - 상태 객체
    @StateObject private var benchmark = ModelBenchmark()
    
    // MARK: - 상태
    @State private var selectedModels: Set<MLModelType> = [.mobileNetV2]
    @State private var selectedComputeUnits: ComputeUnitOption = .all
    @State private var benchmarkMode: BenchmarkMode = .singleModel
    @State private var showingResults = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                // 벤치마크 모드 선택
                Section("벤치마크 모드") {
                    Picker("모드", selection: $benchmarkMode) {
                        ForEach(BenchmarkMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Text(benchmarkMode.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // 모델 선택 (단일 모델 또는 모델 비교 모드)
                if benchmarkMode != .computeUnitsComparison {
                    Section("모델 선택") {
                        ForEach(MLModelType.allCases.filter { $0.category == .imageClassification }) { model in
                            Toggle(isOn: binding(for: model)) {
                                VStack(alignment: .leading) {
                                    Text(model.rawValue)
                                        .font(.headline)
                                    Text(model.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .disabled(benchmarkMode == .singleModel && selectedModels.count == 1 && selectedModels.contains(model))
                        }
                    }
                } else {
                    Section("테스트 모델") {
                        Picker("모델", selection: Binding(
                            get: { selectedModels.first ?? .mobileNetV2 },
                            set: { selectedModels = [$0] }
                        )) {
                            ForEach(MLModelType.allCases.filter { $0.category == .imageClassification }) { model in
                                Text(model.rawValue).tag(model)
                            }
                        }
                    }
                }
                
                // 연산 장치 선택 (연산 장치 비교가 아닌 경우)
                if benchmarkMode != .computeUnitsComparison {
                    Section("연산 장치") {
                        Picker("연산 장치", selection: $selectedComputeUnits) {
                            ForEach(ComputeUnitOption.allCases) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                    }
                }
                
                // 설정
                Section("설정") {
                    Stepper("워밍업 횟수: \(benchmark.warmupIterations)", value: .init(
                        get: { benchmark.warmupIterations },
                        set: { benchmark.warmupIterations = $0 }
                    ), in: 1...20)
                    
                    Stepper("측정 횟수: \(benchmark.measureIterations)", value: .init(
                        get: { benchmark.measureIterations },
                        set: { benchmark.measureIterations = $0 }
                    ), in: 5...100)
                }
                
                // 진행 상태
                if benchmark.isRunning {
                    Section("진행 상태") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(benchmark.statusMessage)
                                .font(.subheadline)
                            
                            ProgressView(value: benchmark.progress)
                            
                            Text("\(Int(benchmark.progress * 100))% 완료")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // 실행 버튼
                Section {
                    Button {
                        Task {
                            await runBenchmark()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            
                            if benchmark.isRunning {
                                ProgressView()
                                    .padding(.trailing, 8)
                            }
                            
                            Text(benchmark.isRunning ? "실행 중..." : "벤치마크 시작")
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                    }
                    .disabled(benchmark.isRunning || selectedModels.isEmpty)
                }
                
                // 결과
                if !benchmark.results.isEmpty {
                    Section("결과") {
                        ForEach(benchmark.results) { result in
                            BenchmarkResultRow(result: result)
                        }
                        
                        Button("결과 초기화") {
                            benchmark.clearResults()
                        }
                        .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("벤치마크")
        }
    }
    
    // MARK: - 토글 바인딩
    private func binding(for model: MLModelType) -> Binding<Bool> {
        Binding(
            get: { selectedModels.contains(model) },
            set: { isSelected in
                if benchmarkMode == .singleModel {
                    // 단일 모델 모드에서는 하나만 선택
                    selectedModels = isSelected ? [model] : selectedModels
                } else {
                    // 모델 비교 모드에서는 여러 개 선택 가능
                    if isSelected {
                        selectedModels.insert(model)
                    } else {
                        selectedModels.remove(model)
                    }
                }
            }
        )
    }
    
    // MARK: - 벤치마크 실행
    private func runBenchmark() async {
        do {
            switch benchmarkMode {
            case .singleModel:
                guard let model = selectedModels.first else { return }
                _ = try await benchmark.benchmark(
                    modelType: model,
                    computeUnits: selectedComputeUnits
                )
                
            case .modelComparison:
                _ = try await benchmark.compareModels(
                    Array(selectedModels),
                    computeUnits: selectedComputeUnits
                )
                
            case .computeUnitsComparison:
                guard let model = selectedModels.first else { return }
                _ = try await benchmark.benchmarkComputeUnits(for: model)
            }
        } catch {
            print("벤치마크 오류: \(error)")
        }
    }
}

// MARK: - 벤치마크 모드
enum BenchmarkMode: String, CaseIterable, Identifiable {
    case singleModel = "단일 모델"
    case modelComparison = "모델 비교"
    case computeUnitsComparison = "연산 장치 비교"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .singleModel:
            return "하나의 모델 성능을 측정합니다"
        case .modelComparison:
            return "여러 모델의 성능을 비교합니다"
        case .computeUnitsComparison:
            return "하나의 모델을 다양한 연산 장치로 테스트합니다"
        }
    }
}

// MARK: - 벤치마크 결과 행
struct BenchmarkResultRow: View {
    let result: BenchmarkResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 모델 및 연산 장치 정보
            HStack {
                Text(result.modelType.rawValue)
                    .font(.headline)
                
                Spacer()
                
                Text(result.computeUnits.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.blue.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            // 성능 수치들
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("평균")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(String(format: "%.2f", result.averageInferenceTimeMs))ms")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                VStack(alignment: .leading) {
                    Text("FPS")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f", result.fps))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.green)
                }
                
                VStack(alignment: .leading) {
                    Text("범위")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(String(format: "%.1f", result.minInferenceTimeMs))-\(String(format: "%.1f", result.maxInferenceTimeMs))ms")
                        .font(.caption)
                }
                
                VStack(alignment: .leading) {
                    Text("표준편차")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("±\(String(format: "%.2f", result.standardDeviationMs))ms")
                        .font(.caption)
                }
            }
            
            // 테스트 횟수
            Text("\(result.iterations)회 테스트")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 프리뷰
#Preview {
    BenchmarkView()
}
