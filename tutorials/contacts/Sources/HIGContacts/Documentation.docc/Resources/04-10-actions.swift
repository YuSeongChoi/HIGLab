import SwiftUI

struct ContactDetailView: View {
    let contact: ContactModel
    
    var body: some View {
        List {
            // 전화번호
            Section("전화번호") {
                ForEach(contact.phoneNumbers, id: \.number) { phone in
                    Button {
                        callNumber(phone.number)
                    } label: {
                        LabeledContent(phone.label, value: phone.number)
                    }
                }
            }
            
            // 이메일
            Section("이메일") {
                ForEach(contact.emails, id: \.self) { email in
                    Button {
                        sendEmail(email)
                    } label: {
                        Text(email)
                    }
                }
            }
        }
        .navigationTitle(contact.fullName)
    }
    
    private func callNumber(_ number: String) {
        let cleaned = number.replacingOccurrences(of: " ", with: "")
        if let url = URL(string: "tel://\(cleaned)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func sendEmail(_ email: String) {
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
}
