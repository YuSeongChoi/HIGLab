import SwiftUI

// MARK: - ContactListView
// 연락처 목록을 표시하는 메인 뷰
// 검색, 정렬, 그룹화 기능 제공

struct ContactListView: View {
    // MARK: - Properties
    
    @EnvironmentObject var contactService: ContactService
    
    /// 새 연락처 추가 시트 표시 여부
    @State private var showingAddContact = false
    
    /// 선택된 연락처 (상세 보기용)
    @State private var selectedContact: Contact?
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Group {
                if contactService.permissionStatus.isAccessible {
                    contactListContent
                } else {
                    permissionDeniedView
                }
            }
            .navigationTitle("연락처")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddContact = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(!contactService.permissionStatus.isAccessible)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        Task {
                            await contactService.refresh()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .searchable(
                text: $contactService.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "이름, 전화번호, 이메일 검색"
            )
            .sheet(isPresented: $showingAddContact) {
                ContactEditView(mode: .add)
            }
            .sheet(item: $selectedContact) { contact in
                ContactDetailView(contact: contact)
            }
            .alert("오류", isPresented: .constant(contactService.errorMessage != nil)) {
                Button("확인") {
                    contactService.clearError()
                }
            } message: {
                Text(contactService.errorMessage ?? "")
            }
        }
    }
    
    // MARK: - Subviews
    
    /// 연락처 목록 콘텐츠
    @ViewBuilder
    private var contactListContent: some View {
        if contactService.isLoading {
            loadingView
        } else if contactService.filteredContacts.isEmpty {
            emptyStateView
        } else {
            contactList
        }
    }
    
    /// 로딩 뷰
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("연락처를 불러오는 중...")
                .foregroundStyle(.secondary)
        }
    }
    
    /// 빈 상태 뷰
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label(
                contactService.searchText.isEmpty ? "연락처 없음" : "검색 결과 없음",
                systemImage: contactService.searchText.isEmpty ? "person.crop.circle" : "magnifyingglass"
            )
        } description: {
            Text(
                contactService.searchText.isEmpty
                ? "새 연락처를 추가해 보세요."
                : "'\(contactService.searchText)'에 대한 검색 결과가 없습니다."
            )
        } actions: {
            if contactService.searchText.isEmpty {
                Button("연락처 추가") {
                    showingAddContact = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    /// 연락처 목록
    private var contactList: some View {
        List {
            ForEach(contactService.groupedContacts, id: \.0) { section, contacts in
                Section(header: Text(section)) {
                    ForEach(contacts) { contact in
                        ContactRowView(contact: contact)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedContact = contact
                            }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    /// 권한 거부 뷰
    private var permissionDeniedView: some View {
        ContentUnavailableView {
            Label("연락처 접근 권한 필요", systemImage: "person.crop.circle.badge.exclamationmark")
        } description: {
            Text(contactService.permissionStatus.message)
        } actions: {
            if contactService.permissionStatus == .notDetermined {
                Button("권한 요청") {
                    contactService.requestAccess()
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("설정으로 이동") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

// MARK: - ContactRowView
// 연락처 목록의 각 행을 표시하는 뷰

struct ContactRowView: View {
    // MARK: - Properties
    
    let contact: Contact
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 12) {
            // 프로필 이미지 또는 이니셜
            profileImage
            
            // 연락처 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(contact.displayName)
                    .font(.body)
                    .fontWeight(.medium)
                
                if !contact.organizationName.isEmpty {
                    Text(contact.organizationName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                if let phone = contact.primaryPhone {
                    Text(phone)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Spacer()
            
            // 빠른 전화 버튼
            if let phone = contact.primaryPhone {
                Button {
                    callPhone(phone)
                } label: {
                    Image(systemName: "phone.fill")
                        .foregroundStyle(.green)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Subviews
    
    /// 프로필 이미지
    @ViewBuilder
    private var profileImage: some View {
        if let imageData = contact.thumbnailImageData,
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 44, height: 44)
                .clipShape(Circle())
        } else {
            // 이니셜 아바타
            Circle()
                .fill(Color.accentColor.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay {
                    Text(contact.initials)
                        .font(.headline)
                        .foregroundStyle(.accent)
                }
        }
    }
    
    // MARK: - Methods
    
    /// 전화 걸기
    private func callPhone(_ number: String) {
        let cleanNumber = number.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        if let url = URL(string: "tel://\(cleanNumber)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Preview

#Preview("연락처 목록") {
    ContactListView()
        .environmentObject(ContactService())
}

#Preview("연락처 행") {
    List {
        ContactRowView(contact: .sample)
        ContactRowView(contact: Contact(
            givenName: "영희",
            familyName: "김",
            organizationName: "테크 스타트업"
        ))
    }
}
