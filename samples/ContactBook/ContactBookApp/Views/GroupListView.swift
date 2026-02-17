import SwiftUI

// MARK: - GroupListView
// 연락처 그룹 목록을 관리하는 뷰
// 그룹 생성, 수정, 삭제 및 멤버 관리 기능 제공

struct GroupListView: View {
    // MARK: - Properties
    
    @EnvironmentObject var contactService: ContactService
    
    /// 새 그룹 추가 알림 표시 여부
    @State private var showingAddGroup = false
    
    /// 새 그룹 이름
    @State private var newGroupName = ""
    
    /// 선택된 그룹 (상세 보기용)
    @State private var selectedGroup: ContactGroup?
    
    /// 편집 중인 그룹
    @State private var editingGroup: ContactGroup?
    
    /// 편집 중인 그룹 이름
    @State private var editingGroupName = ""
    
    /// 삭제 확인용 그룹
    @State private var groupToDelete: ContactGroup?
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Group {
                if contactService.permissionStatus.isAccessible {
                    groupListContent
                } else {
                    permissionDeniedView
                }
            }
            .navigationTitle("그룹")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddGroup = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(!contactService.permissionStatus.isAccessible)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        Task {
                            await contactService.fetchGroups()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .alert("새 그룹", isPresented: $showingAddGroup) {
                TextField("그룹 이름", text: $newGroupName)
                Button("취소", role: .cancel) {
                    newGroupName = ""
                }
                Button("추가") {
                    addGroup()
                }
                .disabled(newGroupName.isEmpty)
            } message: {
                Text("새 그룹의 이름을 입력하세요.")
            }
            .alert("그룹 이름 편집", isPresented: .constant(editingGroup != nil)) {
                TextField("그룹 이름", text: $editingGroupName)
                Button("취소", role: .cancel) {
                    editingGroup = nil
                    editingGroupName = ""
                }
                Button("저장") {
                    updateGroup()
                }
                .disabled(editingGroupName.isEmpty)
            } message: {
                Text("그룹 이름을 수정하세요.")
            }
            .alert("그룹 삭제", isPresented: .constant(groupToDelete != nil)) {
                Button("취소", role: .cancel) {
                    groupToDelete = nil
                }
                Button("삭제", role: .destructive) {
                    deleteGroup()
                }
            } message: {
                if let group = groupToDelete {
                    Text("'\(group.name)' 그룹을 삭제하시겠습니까?\n그룹에 속한 연락처는 삭제되지 않습니다.")
                }
            }
            .sheet(item: $selectedGroup) { group in
                GroupDetailView(group: group)
            }
        }
    }
    
    // MARK: - Subviews
    
    /// 그룹 목록 콘텐츠
    @ViewBuilder
    private var groupListContent: some View {
        if contactService.groups.isEmpty {
            emptyStateView
        } else {
            groupList
        }
    }
    
    /// 빈 상태 뷰
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("그룹 없음", systemImage: "person.3")
        } description: {
            Text("연락처를 분류할 그룹을 만들어 보세요.")
        } actions: {
            Button("그룹 만들기") {
                showingAddGroup = true
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    /// 그룹 목록
    private var groupList: some View {
        List {
            ForEach(contactService.groups) { group in
                GroupRowView(group: group)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedGroup = group
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            groupToDelete = group
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                        
                        Button {
                            editingGroup = group
                            editingGroupName = group.name
                        } label: {
                            Label("편집", systemImage: "pencil")
                        }
                        .tint(.orange)
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
            Button("설정으로 이동") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    // MARK: - Methods
    
    /// 새 그룹 추가
    private func addGroup() {
        guard !newGroupName.isEmpty else { return }
        
        Task {
            await contactService.addGroup(name: newGroupName)
            newGroupName = ""
        }
    }
    
    /// 그룹 이름 수정
    private func updateGroup() {
        guard let group = editingGroup, !editingGroupName.isEmpty else { return }
        
        Task {
            await contactService.updateGroup(group, newName: editingGroupName)
            editingGroup = nil
            editingGroupName = ""
        }
    }
    
    /// 그룹 삭제
    private func deleteGroup() {
        guard let group = groupToDelete else { return }
        
        Task {
            await contactService.deleteGroup(group)
            groupToDelete = nil
        }
    }
}

// MARK: - GroupRowView
// 그룹 목록의 각 행을 표시하는 뷰

struct GroupRowView: View {
    let group: ContactGroup
    
    var body: some View {
        HStack(spacing: 12) {
            // 그룹 아이콘
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "person.3.fill")
                    .foregroundStyle(.accent)
            }
            
            // 그룹 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(group.memberCountText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - GroupDetailView
// 그룹 상세 정보 및 멤버 관리 뷰

struct GroupDetailView: View {
    // MARK: - Properties
    
    @EnvironmentObject var contactService: ContactService
    @Environment(\.dismiss) private var dismiss
    
    let group: ContactGroup
    
    /// 그룹에 속한 연락처 목록
    @State private var members: [Contact] = []
    
    /// 멤버 추가 시트 표시 여부
    @State private var showingAddMember = false
    
    /// 로딩 중 여부
    @State private var isLoading = true
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("멤버 불러오는 중...")
                } else if members.isEmpty {
                    emptyMembersView
                } else {
                    memberList
                }
            }
            .navigationTitle(group.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("닫기") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddMember = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMember) {
                AddMemberToGroupView(group: group, existingMembers: members) { newMember in
                    members.append(newMember)
                }
            }
            .task {
                await loadMembers()
            }
        }
    }
    
    // MARK: - Subviews
    
    /// 빈 멤버 뷰
    private var emptyMembersView: some View {
        ContentUnavailableView {
            Label("멤버 없음", systemImage: "person.badge.plus")
        } description: {
            Text("이 그룹에 연락처를 추가해 보세요.")
        } actions: {
            Button("멤버 추가") {
                showingAddMember = true
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    /// 멤버 목록
    private var memberList: some View {
        List {
            Section {
                ForEach(members) { contact in
                    ContactRowView(contact: contact)
                }
                .onDelete(perform: removeMember)
            } header: {
                Text("\(members.count)명의 멤버")
            }
        }
        .listStyle(.insetGrouped)
    }
    
    // MARK: - Methods
    
    /// 멤버 로드
    private func loadMembers() async {
        members = await contactService.fetchContactsInGroup(group)
        isLoading = false
    }
    
    /// 멤버 제거
    private func removeMember(at offsets: IndexSet) {
        for index in offsets {
            let contact = members[index]
            Task {
                let success = await contactService.removeContact(contact, fromGroup: group)
                if success {
                    members.remove(at: index)
                }
            }
        }
    }
}

// MARK: - AddMemberToGroupView
// 그룹에 멤버 추가 뷰

struct AddMemberToGroupView: View {
    // MARK: - Properties
    
    @EnvironmentObject var contactService: ContactService
    @Environment(\.dismiss) private var dismiss
    
    let group: ContactGroup
    let existingMembers: [Contact]
    let onAdd: (Contact) -> Void
    
    /// 검색어
    @State private var searchText = ""
    
    /// 선택된 연락처
    @State private var selectedContacts: Set<String> = []
    
    // MARK: - Computed Properties
    
    /// 추가 가능한 연락처 (기존 멤버 제외)
    private var availableContacts: [Contact] {
        let existingIds = Set(existingMembers.map { $0.id })
        var contacts = contactService.contacts.filter { !existingIds.contains($0.id) }
        
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            contacts = contacts.filter { contact in
                contact.fullName.lowercased().contains(query) ||
                contact.organizationName.lowercased().contains(query)
            }
        }
        
        return contacts
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(availableContacts) { contact in
                    HStack {
                        ContactRowView(contact: contact)
                        
                        Spacer()
                        
                        if selectedContacts.contains(contact.id) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.accent)
                        } else {
                            Image(systemName: "circle")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        toggleSelection(contact)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchText, prompt: "연락처 검색")
            .navigationTitle("멤버 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("추가 (\(selectedContacts.count))") {
                        addSelectedContacts()
                    }
                    .disabled(selectedContacts.isEmpty)
                    .fontWeight(.semibold)
                }
            }
            .overlay {
                if availableContacts.isEmpty {
                    ContentUnavailableView {
                        Label("추가할 연락처 없음", systemImage: "person.crop.circle")
                    } description: {
                        Text(searchText.isEmpty 
                             ? "모든 연락처가 이미 그룹에 있거나\n연락처가 없습니다."
                             : "검색 결과가 없습니다.")
                    }
                }
            }
        }
    }
    
    // MARK: - Methods
    
    /// 선택 토글
    private func toggleSelection(_ contact: Contact) {
        if selectedContacts.contains(contact.id) {
            selectedContacts.remove(contact.id)
        } else {
            selectedContacts.insert(contact.id)
        }
    }
    
    /// 선택된 연락처 추가
    private func addSelectedContacts() {
        let contactsToAdd = contactService.contacts.filter { selectedContacts.contains($0.id) }
        
        Task {
            for contact in contactsToAdd {
                let success = await contactService.addContact(contact, toGroup: group)
                if success {
                    onAdd(contact)
                }
            }
            dismiss()
        }
    }
}

// MARK: - Preview

#Preview("그룹 목록") {
    GroupListView()
        .environmentObject(ContactService())
}

#Preview("그룹 행") {
    List {
        GroupRowView(group: .sample)
    }
}
