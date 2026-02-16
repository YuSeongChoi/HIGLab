import SwiftUI
import UniformTypeIdentifiers

struct FilePickerView: View {
    @ObservedObject var resourceManager: ResourceManager
    let targetPeer: MCPeerID
    
    @State private var showDocumentPicker = false
    @State private var showPhotoPicker = false
    
    var body: some View {
        VStack(spacing: 20) {
            Button {
                showDocumentPicker = true
            } label: {
                Label("파일 선택", systemImage: "doc")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            
            Button {
                showPhotoPicker = true
            } label: {
                Label("사진 선택", systemImage: "photo")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker { urls in
                for url in urls {
                    _ = resourceManager.sendFile(at: url, to: targetPeer) { error in
                        if let error = error {
                            print("전송 실패: \(error)")
                        }
                    }
                }
            }
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    let onPick: ([URL]) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item])
        picker.allowsMultipleSelection = true
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: ([URL]) -> Void
        
        init(onPick: @escaping ([URL]) -> Void) {
            self.onPick = onPick
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            onPick(urls)
        }
    }
}
