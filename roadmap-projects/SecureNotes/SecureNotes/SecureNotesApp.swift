import SwiftUI
import SwiftData

@main
struct SecureNotesApp: App {
    @State private var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            if authManager.isUnlocked {
                NoteListView()
                    .environment(authManager)
            } else {
                LockScreenView()
                    .environment(authManager)
            }
        }
        .modelContainer(for: SecureNote.self)
    }
}

#Preview {
    NoteListView()
        .environment(AuthManager())
        .modelContainer(for: SecureNote.self, inMemory: true)
}
