import SwiftUI
import UniformTypeIdentifiers

struct VCardDropView: View {
    @State private var isTargeted = false
    @State private var importedContacts: [CNContact] = []
    
    let vCardManager = VCardManager()
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(isTargeted ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                .frame(height: 200)
                .overlay {
                    VStack {
                        Image(systemName: "square.and.arrow.down")
                            .font(.largeTitle)
                        Text("vCard 파일을 여기에 끌어다 놓으세요")
                    }
                    .foregroundStyle(.secondary)
                }
                .cornerRadius(12)
                .onDrop(of: [UTType.vCard], isTargeted: $isTargeted) { providers in
                    handleDrop(providers)
                    return true
                }
            
            // 가져온 연락처 목록
            List(importedContacts, id: \.identifier) { contact in
                Text(CNContactFormatter.string(from: contact, style: .fullName) ?? "")
            }
        }
    }
    
    private func handleDrop(_ providers: [NSItemProvider]) {
        for provider in providers {
            provider.loadDataRepresentation(forTypeIdentifier: UTType.vCard.identifier) { data, _ in
                if let data = data,
                   let contacts = try? vCardManager.parseVCard(data: data) {
                    DispatchQueue.main.async {
                        importedContacts.append(contentsOf: contacts)
                    }
                }
            }
        }
    }
}
