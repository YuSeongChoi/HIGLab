import SwiftUI

// MARK: - 연락처 뷰
// 저장된 연락처 목록을 표시하고 관리하는 화면

/// 연락처 뷰
struct ContactsView: View {
    @EnvironmentObject var contactStore: ContactStore
    @EnvironmentObject var callManager: CallManager
    
    /// 검색어
    @State private var searchText: String = ""
    
    /// 새 연락처 추가 시트
    @State private var showAddContact: Bool = false
    
    /// 선택된 연락처 (상세 보기)
    @State private var selectedContact: Contact?
    
    /// 검색 결과
    private var filteredContacts: [Contact] {
        contactStore.searchContacts(query: searchText)
    }
    
    /// 알파벳순으로 그룹화
    private var groupedContacts: [(String, [Contact])] {
        let sorted = filteredContacts.sorted { $0.name < $1.name }
        let grouped = Dictionary(grouping: sorted) { contact in
            String(contact.name.prefix(1).uppercased())
        }
        return grouped.sorted { $0.key < $1.key }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 즐겨찾기 섹션 (검색 중이 아닐 때)
                if searchText.isEmpty && !contactStore.favoriteContacts.isEmpty {
                    favoritesSection
                }
                
                // 연락처 목록
                contactList
            }
            .navigationTitle("연락처")
            .searchable(text: $searchText, prompt: "이름 또는 전화번호 검색")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showAddContact = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddContact) {
                AddContactSheet()
                    .environmentObject(contactStore)
            }
            .sheet(item: $selectedContact) { contact in
                ContactDetailSheet(contact: contact)
                    .environmentObject(contactStore)
                    .environmentObject(callManager)
            }
        }
    }
    
    // MARK: - 즐겨찾기 섹션
    
    /// 즐겨찾기 가로 스크롤
    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("즐겨찾기")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(contactStore.favoriteContacts) { contact in
                        favoriteCard(contact)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color(.systemGroupedBackground))
    }
    
    /// 즐겨찾기 카드
    private func favoriteCard(_ contact: Contact) -> some View {
        Button(action: {
            callManager.startCall(to: contact.phoneNumber)
        }) {
            VStack(spacing: 8) {
                ContactAvatar(contact: contact, size: 60)
                
                Text(contact.name)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            .frame(width: 80)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                callManager.startCall(to: contact.phoneNumber)
            } label: {
                Label("전화 걸기", systemImage: "phone.fill")
            }
            
            Button {
                selectedContact = contact
            } label: {
                Label("상세 보기", systemImage: "info.circle")
            }
        }
    }
    
    // MARK: - 연락처 목록
    
    /// 연락처 목록
    private var contactList: some View {
        Group {
            if filteredContacts.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(groupedContacts, id: \.0) { section in
                        Section(header: Text(section.0)) {
                            ForEach(section.1) { contact in
                                ContactRow(contact: contact)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedContact = contact
                                    }
                                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                        Button {
                                            callManager.startCall(to: contact.phoneNumber)
                                        } label: {
                                            Label("전화", systemImage: "phone.fill")
                                        }
                                        .tint(.green)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            contactStore.deleteContact(contact)
                                        } label: {
                                            Label("삭제", systemImage: "trash")
                                        }
                                        
                                        Button {
                                            toggleFavorite(contact)
                                        } label: {
                                            Label(
                                                contact.isFavorite ? "즐겨찾기 해제" : "즐겨찾기",
                                                systemImage: contact.isFavorite ? "star.slash" : "star.fill"
                                            )
                                        }
                                        .tint(.yellow)
                                    }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }
    
    /// 즐겨찾기 토글
    private func toggleFavorite(_ contact: Contact) {
        var updated = contact
        updated.isFavorite.toggle()
        contactStore.updateContact(updated)
    }
    
    /// 빈 상태 뷰
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            if searchText.isEmpty {
                Text("연락처가 없습니다")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Button(action: {
                    showAddContact = true
                }) {
                    Label("연락처 추가", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            } else {
                Text("검색 결과가 없습니다")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - 연락처 행

/// 연락처 목록 행 뷰
struct ContactRow: View {
    let contact: Contact
    
    var body: some View {
        HStack(spacing: 12) {
            ContactAvatar(contact: contact, size: 44)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(contact.name)
                        .font(.body)
                        .fontWeight(.medium)
                    
                    if contact.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
                
                Text(contact.formattedPhoneNumber)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 연락처 추가 시트

/// 새 연락처 추가 시트
struct AddContactSheet: View {
    @EnvironmentObject var contactStore: ContactStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var phoneNumber: String = ""
    @State private var email: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("기본 정보") {
                    TextField("이름", text: $name)
                    TextField("전화번호", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    TextField("이메일 (선택)", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }
            }
            .navigationTitle("새 연락처")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("저장") {
                        saveContact()
                    }
                    .disabled(name.isEmpty || phoneNumber.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    /// 연락처 저장
    private func saveContact() {
        let contact = Contact(
            name: name,
            phoneNumber: phoneNumber,
            email: email.isEmpty ? nil : email
        )
        contactStore.addContact(contact)
        dismiss()
    }
}

// MARK: - 연락처 상세 시트

/// 연락처 상세 정보 시트
struct ContactDetailSheet: View {
    let contact: Contact
    @EnvironmentObject var contactStore: ContactStore
    @EnvironmentObject var callManager: CallManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 프로필 영역
                    VStack(spacing: 12) {
                        ContactAvatar(contact: contact, size: 100)
                        
                        Text(contact.name)
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                    .padding(.top)
                    
                    // 액션 버튼
                    HStack(spacing: 20) {
                        actionButton(
                            icon: "phone.fill",
                            label: "전화",
                            color: .green
                        ) {
                            dismiss()
                            callManager.startCall(to: contact.phoneNumber)
                        }
                        
                        actionButton(
                            icon: "message.fill",
                            label: "메시지",
                            color: .blue
                        ) {
                            // 메시지 기능 (미구현)
                        }
                        
                        actionButton(
                            icon: contact.isFavorite ? "star.fill" : "star",
                            label: contact.isFavorite ? "즐겨찾기 해제" : "즐겨찾기",
                            color: .yellow
                        ) {
                            toggleFavorite()
                        }
                    }
                    
                    // 연락처 정보
                    GroupBox {
                        VStack(spacing: 16) {
                            infoRow(
                                icon: "phone",
                                label: "휴대전화",
                                value: contact.formattedPhoneNumber,
                                action: {
                                    callManager.startCall(to: contact.phoneNumber)
                                }
                            )
                            
                            if let email = contact.email {
                                Divider()
                                infoRow(
                                    icon: "envelope",
                                    label: "이메일",
                                    value: email,
                                    action: nil
                                )
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationTitle("연락처")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    /// 액션 버튼
    private func actionButton(
        icon: String,
        label: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(color)
                    )
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(.plain)
    }
    
    /// 정보 행
    private func infoRow(
        icon: String,
        label: String,
        value: String,
        action: (() -> Void)?
    ) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
            }
            
            Spacer()
            
            if let action = action {
                Button(action: action) {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.green)
                }
            }
        }
    }
    
    /// 즐겨찾기 토글
    private func toggleFavorite() {
        var updated = contact
        updated.isFavorite.toggle()
        contactStore.updateContact(updated)
    }
}

// MARK: - 프리뷰

#Preview {
    ContactsView()
        .environmentObject(ContactStore.shared)
        .environmentObject(CallManager.shared)
}
