import SwiftUI
import Contacts

struct GroupListView: View {
    @State private var groups: [CNGroup] = []
    @State private var showAddGroup = false
    @State private var newGroupName = ""
    
    let groupManager = GroupManager()
    
    var body: some View {
        List {
            ForEach(groups, id: \.identifier) { group in
                NavigationLink(destination: GroupDetailView(group: group)) {
                    Label(group.name, systemImage: "person.3")
                }
            }
            .onDelete(perform: deleteGroups)
        }
        .navigationTitle("그룹")
        .toolbar {
            Button("추가") { showAddGroup = true }
        }
        .alert("새 그룹", isPresented: $showAddGroup) {
            TextField("그룹 이름", text: $newGroupName)
            Button("취소", role: .cancel) { newGroupName = "" }
            Button("생성") { createGroup() }
        }
        .task { loadGroups() }
    }
    
    private func loadGroups() {
        groups = (try? groupManager.fetchAllGroups()) ?? []
    }
    
    private func createGroup() {
        guard !newGroupName.isEmpty else { return }
        _ = try? groupManager.createAndSaveGroup(name: newGroupName)
        newGroupName = ""
        loadGroups()
    }
    
    private func deleteGroups(at offsets: IndexSet) {
        for index in offsets {
            let group = groups[index]
            try? groupManager.deleteGroup(identifier: group.identifier)
        }
        loadGroups()
    }
}
