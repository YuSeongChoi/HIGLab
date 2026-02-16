import SwiftUI
import Contacts

struct VCardView: View {
    @Environment(ContactManager.self) private var contactManager
    
    @State private var showExportSheet = false
    @State private var showImportPicker = false
    @State private var exportURL: URL?
    
    let vCardManager = VCardManager()
    
    var body: some View {
        List {
            Section("내보내기") {
                Button("모든 연락처 내보내기") {
                    exportAllContacts()
                }
                
                Button("선택한 연락처 내보내기") {
                    // 선택 UI 표시
                }
            }
            
            Section("가져오기") {
                Button("vCard 파일 가져오기") {
                    showImportPicker = true
                }
            }
        }
        .navigationTitle("vCard")
        .sheet(isPresented: $showExportSheet) {
            if let url = exportURL {
                ShareSheet(items: [url])
            }
        }
        .fileImporter(
            isPresented: $showImportPicker,
            allowedContentTypes: [.vCard]
        ) { result in
            if case .success(let url) = result {
                _ = try? vCardManager.importContactsFromFile(at: url)
            }
        }
    }
    
    private func exportAllContacts() {
        do {
            let url = try vCardManager.saveVCardToFile(
                contacts: contactManager.contacts,
                filename: "AllContacts"
            )
            exportURL = url
            showExportSheet = true
        } catch {
            print("내보내기 실패: \(error)")
        }
    }
}
