#if canImport(PermissionKit)
import PermissionKit
import Contacts
import SwiftUI

// 연락처 목록 뷰
struct ContactsListView: View {
    @State private var contacts: [CNContact] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let store = CNContactStore()
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("연락처 로딩 중...")
                } else if let error = errorMessage {
                    ContentUnavailableView {
                        Label("오류", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error)
                    }
                } else if contacts.isEmpty {
                    ContentUnavailableView {
                        Label("연락처 없음", systemImage: "person.crop.circle")
                    } description: {
                        Text("접근 가능한 연락처가 없습니다.")
                    }
                } else {
                    List(contacts, id: \.identifier) { contact in
                        ContactRow(contact: contact)
                    }
                }
            }
            .navigationTitle("연락처")
            .task {
                await loadContacts()
            }
        }
    }
    
    private func loadContacts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let keysToFetch: [CNKeyDescriptor] = [
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactThumbnailImageDataKey as CNKeyDescriptor
            ]
            
            let request = CNContactFetchRequest(keysToFetch: keysToFetch)
            
            var fetchedContacts: [CNContact] = []
            
            try await Task.detached {
                try self.store.enumerateContacts(with: request) { contact, _ in
                    fetchedContacts.append(contact)
                }
            }.value
            
            await MainActor.run {
                contacts = fetchedContacts.sorted {
                    $0.familyName + $0.givenName < $1.familyName + $1.givenName
                }
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
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
                Text("\(contact.familyName)\(contact.givenName)")
                    .font(.headline)
                
                if let phone = contact.phoneNumbers.first?.value.stringValue {
                    Text(phone)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// iOS 26 PermissionKit - HIG Lab
#endif
