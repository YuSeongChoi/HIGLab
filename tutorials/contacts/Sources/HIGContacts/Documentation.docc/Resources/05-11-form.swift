import SwiftUI
import Contacts

struct AddContactView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ContactManager.self) private var manager
    
    @State private var givenName = ""
    @State private var familyName = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("이름") {
                    TextField("이름", text: $givenName)
                    TextField("성", text: $familyName)
                }
                
                Section("연락처") {
                    TextField("전화번호", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    TextField("이메일", text: $email)
                        .keyboardType(.emailAddress)
                }
            }
            .navigationTitle("새 연락처")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") { saveContact() }
                        .disabled(givenName.isEmpty && familyName.isEmpty)
                }
            }
            .alert("오류", isPresented: $showError) {
                Button("확인") {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveContact() {
        let contact = CNMutableContact()
        contact.givenName = givenName
        contact.familyName = familyName
        
        if !phoneNumber.isEmpty {
            contact.phoneNumbers = [
                CNLabeledValue(
                    label: CNLabelPhoneNumberMobile,
                    value: CNPhoneNumber(stringValue: phoneNumber)
                )
            ]
        }
        
        if !email.isEmpty {
            contact.emailAddresses = [
                CNLabeledValue(label: CNLabelHome, value: email as NSString)
            ]
        }
        
        do {
            try manager.createContact(contact)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
