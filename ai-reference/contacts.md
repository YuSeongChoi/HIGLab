# Contacts AI Reference

> 연락처 접근 및 관리 가이드. 이 문서를 읽고 Contacts 코드를 생성할 수 있습니다.

## 개요

Contacts 프레임워크는 사용자의 연락처에 접근하고 관리하는 기능을 제공합니다.
연락처 조회, 생성, 수정, 삭제를 지원합니다.

## 필수 Import

```swift
import Contacts
import ContactsUI  // UI 컴포넌트 사용 시
```

## 프로젝트 설정 (Info.plist)

```xml
<key>NSContactsUsageDescription</key>
<string>친구를 초대하기 위해 연락처 접근이 필요합니다.</string>
```

## 핵심 구성요소

### 1. CNContactStore (진입점)

```swift
let contactStore = CNContactStore()

// 권한 요청
func requestAccess() async -> Bool {
    do {
        return try await contactStore.requestAccess(for: .contacts)
    } catch {
        return false
    }
}

// 권한 상태 확인
let status = CNContactStore.authorizationStatus(for: .contacts)
switch status {
case .authorized: // 허용됨
case .denied: // 거부됨
case .notDetermined: // 미결정
case .restricted: // 제한됨
case .limited: // 제한적 접근 (iOS 18+)
@unknown default: break
}
```

### 2. 연락처 조회

```swift
// 가져올 키 정의
let keysToFetch: [CNKeyDescriptor] = [
    CNContactGivenNameKey as CNKeyDescriptor,
    CNContactFamilyNameKey as CNKeyDescriptor,
    CNContactPhoneNumbersKey as CNKeyDescriptor,
    CNContactEmailAddressesKey as CNKeyDescriptor,
    CNContactImageDataKey as CNKeyDescriptor,
    CNContactThumbnailImageDataKey as CNKeyDescriptor
]

// 모든 연락처 조회
func fetchAllContacts() throws -> [CNContact] {
    let request = CNContactFetchRequest(keysToFetch: keysToFetch)
    request.sortOrder = .userDefault
    
    var contacts: [CNContact] = []
    try contactStore.enumerateContacts(with: request) { contact, _ in
        contacts.append(contact)
    }
    return contacts
}

// 이름으로 검색
func searchContacts(name: String) throws -> [CNContact] {
    let predicate = CNContact.predicateForContacts(matchingName: name)
    return try contactStore.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
}
```

## 전체 작동 예제

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
            print("연락처 조회 실패: \(error)")
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
            .navigationTitle("연락처")
            .searchable(text: $manager.searchText, prompt: "이름 검색")
            .toolbar {
                if manager.authorizationStatus == .authorized {
                    Button("추가", systemImage: "plus") {
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
                ContentUnavailableView("연락처 없음", systemImage: "person.crop.circle.badge.questionmark")
            }
        }
    }
    
    var requestAccessView: some View {
        ContentUnavailableView {
            Label("연락처 접근 필요", systemImage: "person.crop.circle.badge.exclamationmark")
        } description: {
            Text("연락처를 보려면 접근 권한이 필요합니다")
        } actions: {
            Button("권한 요청") {
                Task { await manager.requestAccess() }
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    var deniedView: some View {
        ContentUnavailableView {
            Label("접근 거부됨", systemImage: "person.crop.circle.badge.minus")
        } description: {
            Text("설정에서 연락처 접근을 허용해주세요")
        } actions: {
            Button("설정 열기") {
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
            // 프로필 이미지
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
                    Section("전화번호") {
                        ForEach(contact.phoneNumbers, id: \.identifier) { phone in
                            LabeledContent(
                                CNLabeledValue<NSString>.localizedString(forLabel: phone.label ?? ""),
                                value: phone.value.stringValue
                            )
                        }
                    }
                }
                
                if !contact.emailAddresses.isEmpty {
                    Section("이메일") {
                        ForEach(contact.emailAddresses, id: \.identifier) { email in
                            Text(email.value as String)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("닫기") { dismiss() }
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
                Section("이름") {
                    TextField("이름", text: $givenName)
                    TextField("성", text: $familyName)
                }
                
                Section("전화번호") {
                    TextField("전화번호", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }
            }
            .navigationTitle("새 연락처")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
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

// CNContact를 Identifiable로
extension CNContact: @retroactive Identifiable {
    public var id: String { identifier }
}
```

## 고급 패턴

### 1. ContactsUI 피커

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

### 2. 연락처 수정

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

### 3. 변경 감지

```swift
NotificationCenter.default.addObserver(
    forName: .CNContactStoreDidChange,
    object: nil,
    queue: .main
) { _ in
    // 연락처 새로고침
    fetchContacts()
}
```

## 주의사항

1. **키 지정 필수**
   - 조회 시 필요한 키만 명시
   - 미지정 키 접근 시 크래시

2. **CNContactViewController 사용 시**
   ```swift
   CNContactViewController.descriptorForRequiredKeys()
   ```

3. **이름 포맷팅**
   ```swift
   CNContactFormatter.string(from: contact, style: .fullName)
   ```

4. **iOS 18 Limited Access**
   - 사용자가 일부 연락처만 허용 가능
   - `.limited` 상태 확인 필요
