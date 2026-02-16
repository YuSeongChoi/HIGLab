import SwiftUI
import Contacts

struct DeleteConfirmView: View {
    @Environment(ContactManager.self) private var manager
    @Environment(\.dismiss) private var dismiss
    
    let contact: CNContact
    @State private var showAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        Button("연락처 삭제", role: .destructive) {
            showAlert = true
        }
        .confirmationDialog(
            "정말 삭제하시겠습니까?",
            isPresented: $showAlert,
            titleVisibility: .visible
        ) {
            Button("삭제", role: .destructive) {
                deleteContact()
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("이 작업은 되돌릴 수 없습니다.")
        }
    }
    
    private func deleteContact() {
        do {
            try manager.deleteContact(identifier: contact.identifier)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
