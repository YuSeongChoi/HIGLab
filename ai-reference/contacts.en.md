# Contacts AI Reference

> Contact access and management guide. Read this document to generate Contacts code.

## Overview

The Contacts framework provides functionality for accessing and managing user contacts.
It supports contact querying, creation, modification, and deletion.

## Required Imports

```swift
import Contacts
import ContactsUI  // When using UI components
```

## Project Setup (Info.plist)

```xml
<key>NSContactsUsageDescription</key>
<string>Contact access is needed to invite friends.</string>
```

## Core Components

### 1. CNContactStore (Entry Point)

```swift
let contactStore = CNContactStore()

// Request permission
func requestAccess() async -> Bool {
    do {
        return try await contactStore.requestAccess(for: .contacts)
    } catch {
        return false
    }
}

// Check authorization status
let status = CNContactStore.authorizationStatus(for: .contacts)
switch status {
case .authorized: // Authorized
case .denied: // Denied
case .notDetermined: // Not determined
case .restricted: // Restricted
case .limited: // Limited access (iOS 18+)
@unknown default: break
}
```

### 2. Fetching Contacts

```swift
// Define keys to fetch
let keysToFetch: [CNKeyDescriptor] = [
    CNContactGivenNameKey as CNKeyDescriptor,
    CNContactFamilyNameKey as CNKeyDescriptor,
    CNContactPhoneNumbersKey as CNKeyDescriptor,
    CNContactEmailAddressesKey as CNKeyDescriptor,
    CNContactImageDataKey as CNKeyDescriptor,
    CNContactThumbnailImageDataKey as CNKeyDescriptor
]

// Fetch all contacts
func fetchAllContacts() throws -> [CNContact] {
    let request = CNContactFetchRequest(keysToFetch: keysToFetch)
    request.sortOrder = .userDefault
    
    var contacts: [CNContact] = []
    try contactStore.enumerateContacts(with: request) { contact, _ in
        contacts.append(contact)
    }
    return contacts
}

// Search by name
func searchContacts(name: String) throws -> [CNContact] {
    let predicate = CNContact.predicateForContacts(matchingName: name)
    return try contactStore.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
}
```

## Complete Working Example

```swift
import SwiftUI
import Contacts
import ContactsUI

// MARK: - Contact Manager
@Observable
class ContactManager {
    let store = CNContactStore()
    var contacts: [CNContact] = []
    var authorizationStatus: CNAuthorizationStatus = .notDetermined
    var searchText = ""
    
    var filteredContacts: [CNContact] {
        if searchText.isEmpty {
            return contacts
        }
        return contacts.filter { contact in
            contact.givenName.localizedCaseInsensitiveContains(searchText) ||
            contact.familyName.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    init() {
        checkAuthorizationStatus()
    }
    
    func checkAuthorizationStatus() {
        authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
    }
    
    func requestAccess() async -> Bool {
        do {
            let granted = try await store.requestAccess(for: .contacts)
            await MainActor.run {
                checkAuthorizationStatus()
                if granted { fetchContacts() }
            }
            return granted
        } catch {
            return false
        }
    }
    
    func fetchContacts() {
        let keys: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactThumbnailImageDataKey as CNKeyDescriptor,
            CNContactViewController.descriptorForRequiredKeys()
        ]
        
        let request = CNContactFetchRequest(keysToFetch: keys)
        request.sortOrder = .userDefault
        
        var fetchedContacts: [CNContact] = []
        
        do {
            try store.enumerateContacts(with: request) { contact, _ in
                fetchedContacts.append(contact)
            }
            contacts = fetchedContacts
        } catch {
            print("Failed to fetch contacts: \(error)")
        }
    }
    
    func createContact(givenName: String, familyName: String, phoneNumber: String) throws {
        let newContact = CNMutableContact()
        newContact.givenName = givenName
        newContact.familyName = familyName
        
        let phone = CNLabeledValue(
            label: CNLabelPhoneNumberMobile,
            value: CNPhoneNumber(stringValue: phoneNumber)
        )
        newContact.phoneNumbers = [phone]
        
        let saveRequest = CNSaveRequest()
        saveRequest.add(newContact, toContainerWithIdentifier: nil)
        
        try store.execute(saveRequest)
        fetchContacts()
    }
    
    func deleteContact(_ contact: CNContact) throws {
        guard let mutableContact = contact.mutableCopy() as? CNMutableContact else { return }
        
        let saveRequest = CNSaveRequest()
        saveRequest.delete(mutableContact)
        
        try store.execute(saveRequest)
        fetchContacts()
    }
}

// MARK: - Views
struct ContactsListView: View {
    @State private var manager = ContactManager()
    @State private var showingAddContact = false
    @State private var selectedContact: CNContact?
    
    var body: some View {
        NavigationStack {
            Group {
                switch manager.authorizationStatus {
                case .authorized:
                    contactListView
                case .notDetermined:
                    requestAccessView
                default:
                    deniedView
                }
            }
            .navigationTitle("Contacts")
            .searchable(text: $manager.searchText, prompt: "Search by name")
            .toolbar {
                if manager.authorizationStatus == .authorized {
                    Button("Add", systemImage: "plus") {
                        showingAddContact = true
                    }
                }
            }
            .sheet(isPresented: $showingAddContact) {
                AddContactView(manager: manager)
            }
            .sheet(item: $selectedContact) { contact in
                ContactDetailView(contact: contact)
            }
        }
    }
    
    var contactListView: some View {
        List {
            ForEach(manager.filteredContacts, id: \.identifier) { contact in
                ContactRow(contact: contact)
                    .onTapGesture {
                        selectedContact = contact
                    }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let contact = manager.filteredContacts[index]
                    try? manager.deleteContact(contact)
                }
            }
        }
        .overlay {
            if manager.contacts.isEmpty {
                ContentUnavailableView("No Contacts", systemImage: "person.crop.circle.badge.questionmark")
            }
        }
    }
    
    var requestAccessView: some View {
        ContentUnavailableView {
            Label("Contacts Access Required", systemImage: "person.crop.circle.badge.exclamationmark")
        } description: {
            Text("Permission is required to view contacts")
        } actions: {
            Button("Request Permission") {
                Task { await manager.requestAccess() }
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    var deniedView: some View {
        ContentUnavailableView {
            Label("Access Denied", systemImage: "person.crop.circle.badge.minus")
        } description: {
            Text("Please allow contacts access in Settings")
        } actions: {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}

struct ContactRow: View {
    let contact: CNContact
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile image
            if let imageData = contact.thumbnailImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.gray)
            }
            
            VStack(alignment: .leading) {
                Text(CNContactFormatter.string(from: contact, style: .fullName) ?? "No Name")
                    .font(.headline)
                
                if let phone = contact.phoneNumbers.first?.value.stringValue {
                    Text(phone)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct ContactDetailView: View {
    let contact: CNContact
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Spacer()
                        VStack {
                            if let imageData = contact.thumbnailImageData,
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 100))
                                    .foregroundStyle(.gray)
                            }
                            
                            Text(CNContactFormatter.string(from: contact, style: .fullName) ?? "")
                                .font(.title2.bold())
                        }
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)
                
                if !contact.phoneNumbers.isEmpty {
                    Section("Phone Numbers") {
                        ForEach(contact.phoneNumbers, id: \.identifier) { phone in
                            LabeledContent(
                                CNLabeledValue<NSString>.localizedString(forLabel: phone.label ?? ""),
                                value: phone.value.stringValue
                            )
                        }
                    }
                }
                
                if !contact.emailAddresses.isEmpty {
                    Section("Email") {
                        ForEach(contact.emailAddresses, id: \.identifier) { email in
                            Text(email.value as String)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Close") { dismiss() }
            }
        }
    }
}

struct AddContactView: View {
    let manager: ContactManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var givenName = ""
    @State private var familyName = ""
    @State private var phoneNumber = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("First Name", text: $givenName)
                    TextField("Last Name", text: $familyName)
                }
                
                Section("Phone Number") {
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }
            }
            .navigationTitle("New Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        try? manager.createContact(
                            givenName: givenName,
                            familyName: familyName,
                            phoneNumber: phoneNumber
                        )
                        dismiss()
                    }
                    .disabled(givenName.isEmpty && familyName.isEmpty)
                }
            }
        }
    }
}

// Make CNContact Identifiable
extension CNContact: @retroactive Identifiable {
    public var id: String { identifier }
}
```

## Advanced Patterns

### 1. ContactsUI Picker

```swift
struct ContactPickerView: UIViewControllerRepresentable {
    @Binding var selectedContact: CNContact?
    
    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        picker.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count > 0")
        return picker
    }
    
    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CNContactPickerDelegate {
        let parent: ContactPickerView
        
        init(_ parent: ContactPickerView) {
            self.parent = parent
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            parent.selectedContact = contact
        }
    }
}
```

### 2. Updating Contacts

```swift
func updateContact(_ contact: CNContact, newPhoneNumber: String) throws {
    guard let mutableContact = contact.mutableCopy() as? CNMutableContact else { return }
    
    let phone = CNLabeledValue(
        label: CNLabelPhoneNumberMobile,
        value: CNPhoneNumber(stringValue: newPhoneNumber)
    )
    mutableContact.phoneNumbers.append(phone)
    
    let saveRequest = CNSaveRequest()
    saveRequest.update(mutableContact)
    
    try store.execute(saveRequest)
}
```

### 3. Change Detection

```swift
NotificationCenter.default.addObserver(
    forName: .CNContactStoreDidChange,
    object: nil,
    queue: .main
) { _ in
    // Refresh contacts
    fetchContacts()
}
```

## Important Notes

1. **Key Specification Required**
   - Only specify keys needed for querying
   - Accessing unspecified keys causes crash

2. **When Using CNContactViewController**
   ```swift
   CNContactViewController.descriptorForRequiredKeys()
   ```

3. **Name Formatting**
   ```swift
   CNContactFormatter.string(from: contact, style: .fullName)
   ```

4. **iOS 18 Limited Access**
   - Users can allow access to only some contacts
   - Need to check `.limited` status
