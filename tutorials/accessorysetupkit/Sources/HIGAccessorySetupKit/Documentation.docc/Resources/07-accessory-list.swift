import SwiftUI

struct AccessoryListView: View {
    @State private var store = AccessoryStore()
    @State private var connectionMonitor = ConnectionMonitor()
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(store.accessories) { accessory in
                    AccessoryRow(
                        accessory: accessory,
                        isConnected: connectionMonitor.isConnected(accessory.bluetoothIdentifier)
                    )
                }
                .onDelete(perform: deleteAccessories)
            }
            .navigationTitle("내 기기")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddAccessoryView(store: store)
            }
        }
    }
    
    private func deleteAccessories(at offsets: IndexSet) {
        for index in offsets {
            store.remove(id: store.accessories[index].id)
        }
    }
}

struct AccessoryRow: View {
    let accessory: AccessoryStore.StoredAccessory
    let isConnected: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "sensor.fill")
                .foregroundStyle(isConnected ? .green : .secondary)
            
            VStack(alignment: .leading) {
                Text(accessory.name)
                    .font(.headline)
                
                if let lastConnected = accessory.lastConnected {
                    Text("마지막 연결: \(lastConnected.formatted(.relative(presentation: .named)))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            if isConnected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
    }
}
