import SwiftUI

struct ContentView: View {
    @Environment(ContactManager.self) private var manager
    
    var body: some View {
        NavigationStack {
            List(manager.contacts, id: \.identifier) { contact in
                Text(contact.givenName + " " + contact.familyName)
            }
            .navigationTitle("연락처")
            .overlay {
                if manager.isLoading {
                    ProgressView()
                }
            }
            .task {
                await manager.refreshContacts()
            }
        }
    }
}
