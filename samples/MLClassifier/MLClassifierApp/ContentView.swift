import SwiftUI
import PhotosUI

// MARK: - 메인 콘텐츠 뷰
// 앱의 메인 탭 구조 및 모델 선택 기능 제공

struct ContentView: View {
    
    // MARK: - 환경 객체
    @EnvironmentObject private var classifier: ImageClassifier
    @EnvironmentObject private var detector: ObjectDetector
    @EnvironmentObject private var analyzer: VisionAnalyzer
    
    // MARK: - 상태
    @State private var selectedTab = 0
    @State private var showingModelPicker = false
    @State private var showingSettings = false
    @State private var selectedModelType: MLModelType = .mobileNetV2
    @State private var selectedComputeUnits: ComputeUnitOption = .all
    
    // MARK: - Body
    var body: some View {
        TabView(selection: $selectedTab) {
            // 탭 1: 사진 분류
            PhotoClassifyView()
                .tabItem {
                    Label("사진", systemImage: "photo")
                }
                .tag(0)
            
            // 탭 2: 실시간 카메라 분류
            CameraClassifyView()
                .tabItem {
                    Label("카메라", systemImage: "camera")
                }
                .tag(1)
            
            // 탭 3: Vision 분석 (텍스트/얼굴/포즈)
            VisionLabView()
                .tabItem {
                    Label("Vision", systemImage: "eye")
                }
                .tag(2)
            
            // 탭 4: 벤치마크
            BenchmarkView()
                .tabItem {
                    Label("벤치마크", systemImage: "gauge.with.dots.needle.33percent")
                }
                .tag(3)
            
            // 탭 5: 모델 정보
            ModelInfoView()
                .tabItem {
                    Label("모델", systemImage: "brain")
                }
                .tag(4)
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Menu {
                    // 모델 선택
                    Menu("모델 선택") {
                        ForEach(MLModelType.allCases.filter { $0.category == .imageClassification }) { model in
                            Button {
                                Task {
                                    selectedModelType = model
                                    try? await classifier.prepareModel(model, computeUnits: selectedComputeUnits)
                                }
                            } label: {
                                HStack {
                                    Text(model.rawValue)
                                    if model == selectedModelType {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    }
                    
                    // 연산 장치 선택
                    Menu("연산 장치") {
                        ForEach(ComputeUnitOption.allCases) { unit in
                            Button {
                                Task {
                                    selectedComputeUnits = unit
                                    try? await classifier.prepareModel(selectedModelType, computeUnits: unit)
                                }
                            } label: {
                                HStack {
                                    Text(unit.rawValue)
                                    if unit == selectedComputeUnits {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    Button {
                        showingSettings = true
                    } label: {
                        Label("설정", systemImage: "gear")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(
                selectedModel: $selectedModelType,
                selectedComputeUnits: $selectedComputeUnits
            )
        }
        .task {
            // 앱 시작 시 기본 모델 로드
            do {
                try await classifier.prepareModel(selectedModelType, computeUnits: selectedComputeUnits)
            } catch {
                print("모델 로드 실패: \(error)")
            }
        }
    }
}

// MARK: - 설정 뷰
struct SettingsView: View {
    @Binding var selectedModel: MLModelType
    @Binding var selectedComputeUnits: ComputeUnitOption
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var classifier: ImageClassifier
    
    // 분류기 설정
    @State private var maxResults: Int = 5
    @State private var minimumConfidence: Float = 0.01
    
    var body: some View {
        NavigationStack {
            Form {
                // 모델 설정 섹션
                Section("모델 설정") {
                    Picker("분류 모델", selection: $selectedModel) {
                        ForEach(MLModelType.allCases.filter { $0.category == .imageClassification }) { model in
                            Text(model.rawValue).tag(model)
                        }
                    }
                    
                    Picker("연산 장치", selection: $selectedComputeUnits) {
                        ForEach(ComputeUnitOption.allCases) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    
                    Text(selectedComputeUnits.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // 분류 설정 섹션
                Section("분류 설정") {
                    Stepper("최대 결과 수: \(maxResults)", value: $maxResults, in: 1...20)
                    
                    VStack(alignment: .leading) {
                        Text("최소 신뢰도: \(String(format: "%.0f%%", minimumConfidence * 100))")
                        Slider(value: $minimumConfidence, in: 0...1, step: 0.01)
                    }
                }
                
                // 정보 섹션
                Section("정보") {
                    LabeledContent("입력 크기", value: "\(Int(selectedModel.expectedInputSize.width))×\(Int(selectedModel.expectedInputSize.height))")
                    LabeledContent("카테고리", value: selectedModel.category.rawValue)
                }
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        // 설정 적용
                        classifier.maxResults = maxResults
                        classifier.minimumConfidence = minimumConfidence
                        
                        Task {
                            try? await classifier.prepareModel(selectedModel, computeUnits: selectedComputeUnits)
                        }
                        
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                maxResults = classifier.maxResults
                minimumConfidence = classifier.minimumConfidence
            }
        }
    }
}

// MARK: - 모델 정보 뷰
struct ModelInfoView: View {
    @StateObject private var modelManager = MLModelManager.shared
    @State private var selectedModelType: MLModelType = .mobileNetV2
    
    var body: some View {
        NavigationStack {
            List {
                // 현재 로드된 모델 섹션
                if let metadata = modelManager.modelMetadata {
                    Section("현재 로드된 모델") {
                        LabeledContent("모델", value: metadata.modelType.rawValue)
                        LabeledContent("연산 장치", value: metadata.computeUnits.rawValue)
                        LabeledContent("로드 시간", value: metadata.loadedAt.formatted(date: .omitted, time: .shortened))
                        
                        if !metadata.inputFeatureNames.isEmpty {
                            LabeledContent("입력", value: metadata.inputFeatureNames.joined(separator: ", "))
                        }
                        
                        if !metadata.outputFeatureNames.isEmpty {
                            LabeledContent("출력", value: metadata.outputFeatureNames.joined(separator: ", "))
                        }
                        
                        if let author = metadata.author {
                            LabeledContent("작성자", value: author)
                        }
                        
                        if let version = metadata.versionString {
                            LabeledContent("버전", value: version)
                        }
                    }
                }
                
                // 사용 가능한 모델들
                Section("사용 가능한 모델") {
                    ForEach(MLModelType.allCases) { modelType in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(modelType.rawValue)
                                    .font(.headline)
                                
                                Spacer()
                                
                                Text(modelType.category.rawValue)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(.blue.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                            
                            Text(modelType.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Text("입력: \(Int(modelType.expectedInputSize.width))×\(Int(modelType.expectedInputSize.height))")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // 연산 장치 정보
                Section("연산 장치 옵션") {
                    ForEach(ComputeUnitOption.allCases) { unit in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(unit.rawValue)
                                .font(.headline)
                            Text(unit.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            .navigationTitle("모델 정보")
        }
    }
}

// MARK: - 프리뷰
#Preview {
    ContentView()
        .environmentObject(ImageClassifier())
        .environmentObject(ObjectDetector())
        .environmentObject(VisionAnalyzer())
}
