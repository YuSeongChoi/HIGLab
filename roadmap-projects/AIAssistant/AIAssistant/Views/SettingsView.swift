import SwiftUI

struct SettingsView: View {
    @AppStorage("systemPrompt") private var systemPrompt = "당신은 친절하고 도움이 되는 AI 어시스턴트입니다."
    @AppStorage("enableSiri") private var enableSiri = true
    @State private var aiManager = AIManager()
    
    var body: some View {
        NavigationStack {
            Form {
                // AI 상태
                Section("AI 상태") {
                    HStack {
                        Text("Foundation Models")
                        Spacer()
                        if aiManager.isAvailable {
                            Label("사용 가능", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else {
                            Label("사용 불가", systemImage: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }
                
                // 시스템 프롬프트
                Section {
                    TextEditor(text: $systemPrompt)
                        .frame(minHeight: 100)
                } header: {
                    Text("시스템 프롬프트")
                } footer: {
                    Text("AI의 기본 성격과 행동을 설정합니다.")
                }
                
                // Siri 통합
                Section {
                    Toggle("Siri 단축어 활성화", isOn: $enableSiri)
                } header: {
                    Text("Siri 통합")
                } footer: {
                    Text("'AI한테 물어봐'로 Siri에서 바로 질문할 수 있습니다.")
                }
                
                // 정보
                Section("정보") {
                    LabeledContent("버전", value: "1.0.0")
                    LabeledContent("최소 iOS", value: "26.0")
                    
                    Link(destination: URL(string: "https://developer.apple.com/documentation/foundationmodels")!) {
                        HStack {
                            Text("Foundation Models 문서")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                        }
                    }
                }
            }
            .navigationTitle("설정")
        }
    }
}

#Preview {
    SettingsView()
}
