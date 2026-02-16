import SwiftUI
import Contacts

struct ContentView: View {
    @State private var showPicker = false
    @State private var selectedContact: CNContact?
    @State private var selectedPhoneNumber: String?
    
    var body: some View {
        VStack(spacing: 20) {
            // 선택된 연락처 표시
            if let contact = selectedContact {
                Text("선택: \(CNContactFormatter.string(from: contact, style: .fullName) ?? "")")
            }
            
            if let phone = selectedPhoneNumber {
                Text("전화번호: \(phone)")
            }
            
            Button("연락처 선택") {
                showPicker = true
            }
            .buttonStyle(.borderedProminent)
        }
        .sheet(isPresented: $showPicker) {
            ContactPickerView { contact in
                selectedContact = contact
                selectedPhoneNumber = contact.phoneNumbers.first?.value.stringValue
            }
        }
    }
}
