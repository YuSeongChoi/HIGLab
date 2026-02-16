import SwiftUI
import Contacts

struct EditContactView: View {
    @Environment(ContactManager.self) private var manager
    @Environment(\.dismiss) private var dismiss
    
    let contactIdentifier: String
    
    @State private var givenName = ""
    @State private var familyName = ""
    @State private var phoneNumbers: [String] = []
    @State private var showDeleteAlert = false
    
    var body: some View {
        Form {
            Section("이름") {
                TextField("이름", text: $givenName)
                TextField("성", text: $familyName)
            }
            
            Section("전화번호") {
                ForEach(phoneNumbers.indices, id: \.self) { index in
                    TextField("전화번호", text: $phoneNumbers[index])
                        .keyboardType(.phonePad)
                }
                .onDelete(perform: deletePhoneNumber)
                
                Button("전화번호 추가") {
                    phoneNumbers.append("")
                }
            }
            
            Section {
                Button("연락처 삭제", role: .destructive) {
                    showDeleteAlert = true
                }
            }
        }
        .navigationTitle("연락처 편집")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("저장") { saveChanges() }
            }
        }
        .task { loadContact() }
        .alert("삭제 확인", isPresented: $showDeleteAlert) {
            Button("삭제", role: .destructive) { deleteContact() }
            Button("취소", role: .cancel) {}
        }
    }
    
    private func loadContact() {
        // 연락처 정보 로드
    }
    
    private func saveChanges() {
        // 변경사항 저장
        dismiss()
    }
    
    private func deletePhoneNumber(at offsets: IndexSet) {
        phoneNumbers.remove(atOffsets: offsets)
    }
    
    private func deleteContact() {
        try? manager.deleteContact(identifier: contactIdentifier)
        dismiss()
    }
}
