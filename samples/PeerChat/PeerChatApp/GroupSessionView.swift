// GroupSessionView.swift
// PeerChat - MultipeerConnectivity 기반 P2P 채팅
// 그룹 세션 관리 화면

import SwiftUI
import MultipeerConnectivity

/// 그룹 세션 목록 뷰
struct GroupSessionView: View {
    @EnvironmentObject var multipeerService: MultipeerService
    @State private var showingCreateGroup = false
    
    var body: some View {
        List {
            // 활성 그룹 섹션
            activeGroupsSection
            
            // 비활성 그룹 섹션
            if !inactiveGroups.isEmpty {
                inactiveGroupsSection
            }
        }
        .navigationTitle("그룹")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingCreateGroup = true
                } label: {
                    Image(systemName: "plus")
                }
                .disabled(multipeerService.connectedPeers.isEmpty)
            }
        }
        .sheet(isPresented: $showingCreateGroup) {
            CreateGroupView()
        }
        .overlay {
            if multipeerService.groupSessions.isEmpty {
                ContentUnavailableView(
                    "그룹 없음",
                    systemImage: "person.3",
                    description: Text("연결된 기기들과 그룹을 만들어 단체 채팅을 시작하세요")
                )
            }
        }
    }
    
    // MARK: - Active Groups Section
    
    private var activeGroups: [GroupSession] {
        multipeerService.groupSessions.filter { $0.isActive }
    }
    
    private var inactiveGroups: [GroupSession] {
        multipeerService.groupSessions.filter { !$0.isActive }
    }
    
    private var activeGroupsSection: some View {
        Section {
            ForEach(activeGroups) { group in
                NavigationLink(destination: GroupChatView(group: group)) {
                    GroupRow(group: group)
                }
            }
            .onDelete { indexSet in
                deleteGroups(at: indexSet, from: activeGroups)
            }
        } header: {
            if !activeGroups.isEmpty {
                Text("활성 그룹")
            }
        }
    }
    
    private var inactiveGroupsSection: some View {
        Section {
            ForEach(inactiveGroups) { group in
                GroupRow(group: group, isInactive: true)
            }
            .onDelete { indexSet in
                deleteGroups(at: indexSet, from: inactiveGroups)
            }
        } header: {
            Text("비활성 그룹")
        }
    }
    
    private func deleteGroups(at indexSet: IndexSet, from groups: [GroupSession]) {
        for index in indexSet {
            let group = groups[index]
            multipeerService.deleteGroup(group.id)
        }
    }
}

/// 그룹 행 뷰
struct GroupRow: View {
    let group: GroupSession
    var isInactive: Bool = false
    @EnvironmentObject var multipeerService: MultipeerService
    
    var body: some View {
        HStack(spacing: 12) {
            // 그룹 아이콘
            Image(systemName: "person.3.fill")
                .font(.title3)
                .foregroundStyle(isInactive ? .secondary : .tint)
                .frame(width: 44, height: 44)
                .background(Color.accentColor.opacity(isInactive ? 0.05 : 0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.headline)
                    .foregroundStyle(isInactive ? .secondary : .primary)
                
                HStack(spacing: 4) {
                    Image(systemName: "person.2")
                        .font(.caption)
                    
                    Text("\(group.memberCount)명")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // 마지막 메시지 시간
            if let lastMessage = multipeerService.lastMessage(for: group.id.uuidString) {
                Text(lastMessage.formattedTime)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

/// 그룹 생성 뷰
struct CreateGroupView: View {
    @EnvironmentObject var multipeerService: MultipeerService
    @Environment(\.dismiss) private var dismiss
    
    @State private var groupName = ""
    @State private var selectedMembers: Set<String> = []
    
    var body: some View {
        NavigationStack {
            Form {
                // 그룹 이름 섹션
                Section("그룹 이름") {
                    TextField("그룹 이름을 입력하세요", text: $groupName)
                }
                
                // 멤버 선택 섹션
                Section {
                    ForEach(multipeerService.connectedPeers) { peer in
                        MemberSelectionRow(
                            peer: peer,
                            isSelected: selectedMembers.contains(peer.id)
                        ) {
                            toggleMember(peer.id)
                        }
                    }
                } header: {
                    Text("멤버 선택")
                } footer: {
                    Text("그룹에 포함할 멤버를 선택하세요. 최소 2명이 필요합니다.")
                }
            }
            .navigationTitle("새 그룹")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("만들기") {
                        createGroup()
                    }
                    .disabled(!canCreateGroup)
                }
            }
        }
    }
    
    private var canCreateGroup: Bool {
        !groupName.trimmingCharacters(in: .whitespaces).isEmpty &&
        selectedMembers.count >= 2
    }
    
    private func toggleMember(_ memberID: String) {
        if selectedMembers.contains(memberID) {
            selectedMembers.remove(memberID)
        } else {
            selectedMembers.insert(memberID)
        }
    }
    
    private func createGroup() {
        let members = multipeerService.connectedPeers.filter {
            selectedMembers.contains($0.id)
        }
        
        _ = multipeerService.createGroupSession(
            name: groupName,
            members: members
        )
        
        dismiss()
    }
}

/// 멤버 선택 행
struct MemberSelectionRow: View {
    let peer: DiscoveredPeer
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: peer.deviceIcon)
                    .font(.title3)
                    .foregroundStyle(.tint)
                    .frame(width: 36, height: 36)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(Circle())
                
                Text(peer.displayName)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? .tint : .secondary)
                    .font(.title3)
            }
        }
    }
}

/// 그룹 채팅 뷰
struct GroupChatView: View {
    let group: GroupSession
    
    @EnvironmentObject var multipeerService: MultipeerService
    @State private var messageText = ""
    @State private var showingGroupInfo = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // 메시지 목록
            messageList
            
            // 입력 영역
            inputArea
        }
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingGroupInfo = true
                } label: {
                    Image(systemName: "info.circle")
                }
            }
        }
        .sheet(isPresented: $showingGroupInfo) {
            GroupInfoView(group: group)
        }
        .alert("오류", isPresented: $showingError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Message List
    
    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(multipeerService.getMessages(for: group.id.uuidString)) { message in
                        MessageBubbleView(
                            message: message,
                            isFromMe: message.senderID == multipeerService.localDisplayName
                        )
                        .id(message.id)
                    }
                }
                .padding()
            }
            .onChange(of: multipeerService.getMessages(for: group.id.uuidString).count) { _, _ in
                if let lastMessage = multipeerService.getMessages(for: group.id.uuidString).last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    // MARK: - Input Area
    
    private var inputArea: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 12) {
                TextField("메시지", text: $messageText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .focused($isInputFocused)
                    .lineLimit(1...5)
                
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundStyle(messageText.isEmpty ? .gray : .tint)
                }
                .disabled(messageText.isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
        }
    }
    
    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        do {
            try multipeerService.sendMessage(text, toGroup: group.id)
            messageText = ""
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}

/// 그룹 정보 뷰
struct GroupInfoView: View {
    let group: GroupSession
    
    @EnvironmentObject var multipeerService: MultipeerService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                // 그룹 정보 헤더
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.tint)
                        
                        Text(group.name)
                            .font(.title2.bold())
                        
                        Text("생성일: \(group.createdAt.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }
                .listRowBackground(Color.clear)
                
                // 멤버 목록
                Section {
                    ForEach(group.memberIDs, id: \.self) { memberID in
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundStyle(.secondary)
                            
                            Text(memberID)
                            
                            Spacer()
                            
                            if isOnline(memberID) {
                                Text("온라인")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                            } else {
                                Text("오프라인")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("멤버 (\(group.memberCount))")
                }
                
                // 그룹 나가기
                Section {
                    Button(role: .destructive) {
                        multipeerService.deleteGroup(group.id)
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("그룹 삭제")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("그룹 정보")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func isOnline(_ memberID: String) -> Bool {
        multipeerService.connectedPeers.contains { $0.id == memberID }
    }
}

#Preview {
    NavigationStack {
        GroupSessionView()
            .environmentObject(MultipeerService())
    }
}
