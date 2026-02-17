import SwiftUI
import PhotosUI

// MARK: - 메인 콘텐츠 뷰
// 사진 선택 및 분류 결과 표시

struct ContentView: View {
    
    // MARK: - 환경 객체
    @EnvironmentObject private var classifier: ImageClassifier
    
    // MARK: - 상태
    @State private var selectedTab = 0
    @State private var showingModelPicker = false
    @State private var selectedModelType: MLModelType = .mobileNetV2
    
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
        }
        .toolbar {
            // 모델 선택 버튼
            ToolbarItem(placement: .automatic) {
                Button {
                    showingModelPicker = true
                } label: {
                    Label("모델", systemImage: "brain")
                }
            }
        }
        .sheet(isPresented: $showingModelPicker) {
            ModelPickerView(selectedModel: $selectedModelType)
        }
        .task {
            // 앱 시작 시 기본 모델 로드
            do {
                try await classifier.prepareModel(selectedModelType)
            } catch {
                print("모델 로드 실패: \(error)")
            }
        }
    }
}

// MARK: - 모델 선택 뷰
struct ModelPickerView: View {
    @Binding var selectedModel: MLModelType
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var classifier: ImageClassifier
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(MLModelType.allCases) { model in
                    Button {
                        selectedModel = model
                        Task {
                            try? await classifier.prepareModel(model)
                        }
                        dismiss()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(model.rawValue)
                                    .font(.headline)
                                Text(model.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            if model == selectedModel {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                    .foregroundStyle(.primary)
                }
            }
            .navigationTitle("ML 모델 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - 프리뷰
#Preview {
    ContentView()
        .environmentObject(ImageClassifier())
}
