import SwiftUI
import Contacts

struct GroupDetailView: View {
    let group: CNGroup
    
    @State private var members: [CNContact] = []
    @State private var showContactPicker = false
    
    let groupManager = GroupManager()
    
    var body: some View {
        List {
            Section("멤버 (\(members.count)명)") {
                ForEach(members, id: \.identifier) { contact in
                    Text(CNContactFormatter.string(from: contact, style: .fullName) ?? "이름 없음")
                }
                .onDelete(perform: removeMembers)
            }
        }
        .navigationTitle(group.name)
        .toolbar {
            Button {
                showContactPicker = true
            } label: {
                Image(systemName: "person.badge.plus")
            }
        }
        .sheet(isPresented: $showContactPicker) {
            // ContactPickerView (Chapter 8에서 구현)
            Text("연락처 선택")
        }
        .task { loadMembers() }
    }
    
    private func loadMembers() {
        members = (try? groupManager.fetchContacts(inGroup: group)) ?? []
    }
    
    private func removeMembers(at offsets: IndexSet) {
        for index in offsets {
            let contact = members[index]
            try? groupManager.removeContact(contact, fromGroup: group)
        }
        loadMembers()
    }
}
