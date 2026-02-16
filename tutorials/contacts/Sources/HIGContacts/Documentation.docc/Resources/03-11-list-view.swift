import SwiftUI
import Contacts

struct ContactListView: View {
    @Environment(ContactManager.self) private var manager
    @State private var searchText = ""
    
    var filteredContacts: [CNContact] {
        if searchText.isEmpty {
            return manager.contacts
        }
        return manager.contacts.filter { contact in
            let fullName = CNContactFormatter.string(
                from: contact,
                style: .fullName
            ) ?? ""
            return fullName.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        List(filteredContacts, id: \.identifier) { contact in
            ContactRow(contact: contact)
        }
        .searchable(text: $searchText, prompt: "이름 검색")
    }
}

struct ContactRow: View {
    let contact: CNContact
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(CNContactFormatter.string(from: contact, style: .fullName) ?? "이름 없음")
                .font(.headline)
            
            if let phone = contact.phoneNumbers.first?.value.stringValue {
                Text(phone)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
