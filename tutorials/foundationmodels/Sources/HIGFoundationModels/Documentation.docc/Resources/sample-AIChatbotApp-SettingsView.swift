// SettingsView.swift
// 챗봇 설정 화면
// iOS 26+ | FoundationModels

import SwiftUI
import FoundationModels

/// 설정 화면
struct SettingsView: View {
    
    @Environment(ConversationStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    
    @State private var systemPrompt: String = ""
    @State private var modelAvailability: SystemLanguageModel.Availability = .available
    
    var body: some View {
        NavigationStack {
            Form {
                // 모델 정보 섹션
                modelInfoSection
                
                // 시스템 프롬프트 섹션
                systemPromptSection
                
                // 대화 관리 섹션
                conversationSection
                
                // 앱 정보 섹션
                aboutSection
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") {
                        saveSettings()
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadSettings()
            }
            .task {
                modelAvailability = await ChatManager.checkAvailability()
            }
        }
    }
    
    // MARK: - 모델 정보 섹션
    
    private var modelInfoSection: some View {
        Section {
            HStack {
                Label("상태", systemImage: "cpu")
                Spacer()
                availabilityBadge
            }
            
            HStack {
                Label("엔진", systemImage: "brain")
                Spacer()
                Text("Apple Intelligence")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("언어 모델")
        } footer: {
            Text("FoundationModels 프레임워크를 사용하여 온디바이스에서 실행됩니다.")
        }
    }
    
    /// 모델 가용성 뱃지
    private var availabilityBadge: some View {
        Group {
            switch modelAvailability {
            case .available:
                Label("사용 가능", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            case .unavailable:
                Label("사용 불가", systemImage: "xmark.circle.fill")
                    .foregroundStyle(.red)
            @unknown default:
                Label("알 수 없음", systemImage: "questionmark.circle.fill")
                    .foregroundStyle(.orange)
            }
        }
        .font(.footnote)
        .labelStyle(.titleAndIcon)
    }
    
    // MARK: - 시스템 프롬프트 섹션
    
    private var systemPromptSection: some View {
        Section {
            TextEditor(text: $systemPrompt)
                .frame(minHeight: 100)
            
            Button("기본값으로 재설정") {
                systemPrompt = defaultSystemPrompt
            }
            .foregroundStyle(.red)
        } header: {
            Text("시스템 프롬프트")
        } footer: {
            Text("AI의 성격과 행동 방식을 정의합니다. 변경 후 새 대화를 시작하면 적용됩니다.")
        }
    }
    
    // MARK: - 대화 관리 섹션
    
    private var conversationSection: some View {
        Section {
            HStack {
                Label("메시지 수", systemImage: "text.bubble")
                Spacer()
                Text("\(store.messages.count)")
                    .foregroundStyle(.secondary)
            }
            
            Button(role: .destructive) {
                store.clearConversation()
            } label: {
                Label("대화 내역 삭제", systemImage: "trash")
            }
            .disabled(store.messages.isEmpty)
        } header: {
            Text("대화")
        }
    }
    
    // MARK: - 앱 정보 섹션
    
    private var aboutSection: some View {
        Section {
            HStack {
                Label("버전", systemImage: "info.circle")
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Label("최소 iOS", systemImage: "iphone")
                Spacer()
                Text("iOS 26.0+")
                    .foregroundStyle(.secondary)
            }
            
            Link(destination: URL(string: "https://developer.apple.com/documentation/foundationmodels")!) {
                Label("FoundationModels 문서", systemImage: "book")
            }
        } header: {
            Text("정보")
        }
    }
    
    // MARK: - 헬퍼
    
    private var defaultSystemPrompt: String {
        "당신은 친절하고 도움이 되는 AI 어시스턴트입니다. 한국어로 답변해주세요."
    }
    
    private func loadSettings() {
        systemPrompt = store.chatManager.systemPrompt
    }
    
    private func saveSettings() {
        store.chatManager.systemPrompt = systemPrompt
    }
}

// MARK: - 프리뷰

#Preview {
    SettingsView()
        .environment(ConversationStore.preview)
}
