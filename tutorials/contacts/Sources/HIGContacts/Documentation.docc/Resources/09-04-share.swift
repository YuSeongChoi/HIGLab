import SwiftUI
import Contacts

struct ShareVCardView: View {
    let contact: CNContact
    
    @State private var showShareSheet = false
    @State private var vCardURL: URL?
    
    var body: some View {
        Button("연락처 공유") {
            exportAndShare()
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = vCardURL {
                ShareSheet(items: [url])
            }
        }
    }
    
    private func exportAndShare() {
        do {
            let manager = VCardManager()
            let url = try manager.saveVCardToFile(
                contacts: [contact],
                filename: contact.givenName
            )
            vCardURL = url
            showShareSheet = true
        } catch {
            print("내보내기 실패: \(error)")
        }
    }
}

// UIActivityViewController 래퍼
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
