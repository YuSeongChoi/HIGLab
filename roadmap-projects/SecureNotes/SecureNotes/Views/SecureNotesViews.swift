import SwiftUI
import SwiftData

// MARK: - Lock Screen
struct LockScreenView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var isAuthenticating = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundStyle(.accent)
            
            Text("SecureNotes")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("안전하게 보호된 메모")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Button {
                authenticate()
            } label: {
                HStack {
                    Image(systemName: biometricIcon)
                    Text("잠금 해제")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
            .disabled(isAuthenticating)
        }
        .padding()
        .onAppear {
            authenticate()
        }
    }
    
    private var biometricIcon: String {
        switch authManager.biometricType {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        case .none: return "lock"
        }
    }
    
    private func authenticate() {
        isAuthenticating = true
        Task {
            await authManager.authenticateWithBiometrics()
            isAuthenticating = false
        }
    }
}

// MARK: - Note List
struct NoteListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AuthManager.self) private var authManager
    @Query(sort: \SecureNote.updatedAt, order: .reverse) private var notes: [SecureNote]
    
    @State private var showNewNote = false
    
    var body: some View {
        NavigationStack {
            Group {
                if notes.isEmpty {
                    ContentUnavailableView(
                        "메모가 없습니다",
                        systemImage: "note.text",
                        description: Text("새 메모를 추가하세요")
                    )
                } else {
                    List {
                        ForEach(notes) { note in
                            NavigationLink {
                                NoteDetailView(note: note)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(note.title)
                                        .font(.headline)
                                    Text(note.updatedAt.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .onDelete(perform: deleteNotes)
                    }
                }
            }
            .navigationTitle("보안 메모")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        authManager.lock()
                    } label: {
                        Image(systemName: "lock")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNewNote = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNewNote) {
                NewNoteView()
            }
        }
    }
    
    private func deleteNotes(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(notes[index])
        }
    }
}

// MARK: - New Note
struct NewNoteView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager
    
    @State private var title = ""
    @State private var content = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("제목", text: $title)
                
                Section("내용") {
                    TextEditor(text: $content)
                        .frame(minHeight: 200)
                }
            }
            .navigationTitle("새 메모")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        saveNote()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveNote() {
        guard let key = authManager.encryptionKey else { return }
        
        do {
            let note = try SecureNote(title: title, content: content, key: key)
            modelContext.insert(note)
            dismiss()
        } catch {
            print("암호화 실패: \(error)")
        }
    }
}

// MARK: - Note Detail
struct NoteDetailView: View {
    @Environment(AuthManager.self) private var authManager
    let note: SecureNote
    
    @State private var decryptedContent = ""
    @State private var isEditing = false
    @State private var editedContent = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(note.updatedAt.formatted())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if isEditing {
                    TextEditor(text: $editedContent)
                        .frame(minHeight: 300)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Text(decryptedContent)
                        .font(.body)
                }
            }
            .padding()
        }
        .navigationTitle(note.title)
        .toolbar {
            Button(isEditing ? "완료" : "편집") {
                if isEditing {
                    saveChanges()
                } else {
                    editedContent = decryptedContent
                }
                isEditing.toggle()
            }
        }
        .onAppear {
            decryptNote()
        }
    }
    
    private func decryptNote() {
        guard let key = authManager.encryptionKey else { return }
        
        do {
            decryptedContent = try note.decrypt(with: key)
        } catch {
            decryptedContent = "복호화 실패"
        }
    }
    
    private func saveChanges() {
        guard let key = authManager.encryptionKey else { return }
        
        do {
            try note.update(content: editedContent, key: key)
            decryptedContent = editedContent
        } catch {
            print("저장 실패: \(error)")
        }
    }
}

#Preview {
    LockScreenView()
        .environment(AuthManager())
}
