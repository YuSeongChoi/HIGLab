import SwiftUI

@main
struct ContactsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(ContactManager.shared)
        }
    }
}
