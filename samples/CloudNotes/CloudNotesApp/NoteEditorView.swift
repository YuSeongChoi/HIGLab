// NoteEditorView.swift
// CloudNotes - 노트 편집 화면
//
// 노트 생성 및 편집 기능을 제공합니다.

import SwiftUI

// MARK: - NoteEditorView

/// 노트 편집 뷰
struct NoteEditorView: View {
    
    // MARK: - 환경
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var cloudKitManager: CloudKitManager
    
    // MARK: - 속성
    
    /// 편집할 노트 (nil이면 새 노트 생성)
    let note: Note?
    
    // MARK: - 상태
    
    /// 제목 텍스트
    @State private var title: String
    
    /// 내용 텍스트
    @State private var content: String
    
    /// 저장 중 상태
    @State private var isSaving = false
    
    /// 공유 시트 표시 여부
    @State private var showingShareSheet = false
    
    /// 삭제 확인 알림 표시 여부
    @State private var showingDeleteAlert = false
    
    /// 에러 알림 표시 여부
    @State private var showingError = false
    
    /// 에러 메시지
    @State private var errorMessage = ""
    
    /// 제목 포커스 여부
    @FocusState private var isTitleFocused: Bool
    
    // MARK: - 초기화
    
    init(note: Note?) {
        self.note = note
        // 기존 노트 값으로 초기화, 없으면 빈 값
        _title = State(initialValue: note?.title ?? "")
        _content = State(initialValue: note?.content ?? "")
    }
    
    // MARK: - 계산 속성
    
    /// 새 노트인지 여부
    var isNewNote: Bool {
        note == nil
    }
    
    /// 변경사항이 있는지 여부
    var hasChanges: Bool {
        if let note = note {
            return title != note.title || content != note.content
        } else {
            return !title.isEmpty || !content.isEmpty
        }
    }
    
    /// 저장 가능 여부
    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 제목 입력
                titleField
                
                Divider()
                
                // 내용 입력
                contentEditor
            }
            .navigationTitle(isNewNote ? "새 노트" : "노트 편집")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .onAppear {
                // 새 노트일 경우 제목에 포커스
                if isNewNote {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isTitleFocused = true
                    }
                }
            }
            .alert("오류", isPresented: $showingError) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .alert("노트 삭제", isPresented: $showingDeleteAlert) {
                Button("취소", role: .cancel) {}
                Button("삭제", role: .destructive) {
                    deleteNote()
                }
            } message: {
                Text("이 노트를 삭제하시겠습니까?\n이 작업은 취소할 수 없습니다.")
            }
            .sheet(isPresented: $showingShareSheet) {
                if let note = note {
                    ShareView(note: note)
                }
            }
            .interactiveDismissDisabled(hasChanges)
        }
    }
    
    // MARK: - 서브뷰
    
    /// 제목 입력 필드
    private var titleField: some View {
        TextField("제목", text: $title, axis: .vertical)
            .font(.title2.weight(.semibold))
            .padding()
            .focused($isTitleFocused)
    }
    
    /// 내용 편집기
    private var contentEditor: some View {
        TextEditor(text: $content)
            .font(.body)
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .scrollContentBackground(.hidden)
            .overlay(alignment: .topLeading) {
                // 플레이스홀더
                if content.isEmpty {
                    Text("내용을 입력하세요...")
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .allowsHitTesting(false)
                }
            }
    }
    
    /// 툴바 콘텐츠
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        // 왼쪽: 취소/닫기
        ToolbarItem(placement: .cancellationAction) {
            Button(hasChanges ? "취소" : "닫기") {
                dismiss()
            }
            .disabled(isSaving)
        }
        
        // 오른쪽: 저장
        ToolbarItem(placement: .confirmationAction) {
            if isSaving {
                ProgressView()
            } else {
                Button("저장") {
                    saveNote()
                }
                .fontWeight(.semibold)
                .disabled(!canSave || !hasChanges)
            }
        }
        
        // 하단 툴바 (기존 노트일 경우)
        if !isNewNote {
            ToolbarItemGroup(placement: .bottomBar) {
                // 삭제
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                }
                .disabled(isSaving)
                
                Spacer()
                
                // 정보 (수정일)
                if let modifiedAt = note?.modifiedAt {
                    Text("수정됨: \(modifiedAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // 공유
                Button {
                    showingShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .disabled(isSaving)
            }
        }
    }
    
    // MARK: - 액션
    
    /// 노트 저장
    private func saveNote() {
        isSaving = true
        
        Task {
            do {
                // 기존 노트 업데이트 또는 새 노트 생성
                var noteToSave: Note
                if let existingNote = note {
                    noteToSave = existingNote
                    noteToSave.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
                    noteToSave.content = content
                } else {
                    noteToSave = Note(
                        title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                        content: content
                    )
                }
                
                try await cloudKitManager.save(noteToSave)
                
                await MainActor.run {
                    isSaving = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    errorMessage = "저장 실패: \(error.localizedDescription)"
                    showingError = true
                }
            }
        }
    }
    
    /// 노트 삭제
    private func deleteNote() {
        guard let note = note else { return }
        
        isSaving = true
        
        Task {
            do {
                try await cloudKitManager.delete(note)
                
                await MainActor.run {
                    isSaving = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    errorMessage = "삭제 실패: \(error.localizedDescription)"
                    showingError = true
                }
            }
        }
    }
}

// MARK: - 미리보기

#Preview("새 노트") {
    NoteEditorView(note: nil)
        .environmentObject(CloudKitManager.shared)
}

#Preview("노트 편집") {
    NoteEditorView(note: .sample)
        .environmentObject(CloudKitManager.shared)
}
