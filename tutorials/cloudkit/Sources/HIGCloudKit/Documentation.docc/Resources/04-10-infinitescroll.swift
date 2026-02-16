import CloudKit
import SwiftUI

/// 무한 스크롤을 위한 ViewModel
@MainActor
final class NotesViewModel: ObservableObject {
    
    @Published var notes: [Note] = []
    @Published var isLoading = false
    @Published var hasMore = true
    
    private var cursor: CKQueryOperation.Cursor?
    private let manager = CloudKitManager.shared
    
    /// 초기 로드
    func loadInitialNotes() async {
        guard !isLoading else { return }
        isLoading = true
        
        do {
            let result = try await manager.fetchNotesPage()
            notes = result.notes
            cursor = result.cursor
            hasMore = result.hasMore
        } catch {
            print("Error loading notes: \(error)")
        }
        
        isLoading = false
    }
    
    /// 다음 페이지 로드
    func loadMoreIfNeeded(currentNote: Note) async {
        // 마지막 아이템에 도달했을 때
        guard let lastNote = notes.last,
              lastNote.id == currentNote.id,
              hasMore,
              !isLoading,
              let cursor = cursor else {
            return
        }
        
        isLoading = true
        
        do {
            let result = try await manager.fetchNotesPage(after: cursor)
            notes.append(contentsOf: result.notes)
            self.cursor = result.cursor
            hasMore = result.hasMore
        } catch {
            print("Error loading more: \(error)")
        }
        
        isLoading = false
    }
}
