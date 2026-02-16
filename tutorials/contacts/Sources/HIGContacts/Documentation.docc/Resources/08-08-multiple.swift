import ContactsUI
import SwiftUI

struct MultiContactPickerView: UIViewControllerRepresentable {
    var onSelect: ([CNContact]) -> Void
    
    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CNContactPickerDelegate {
        let parent: MultiContactPickerView
        
        init(_ parent: MultiContactPickerView) {
            self.parent = parent
        }
        
        // 다중 연락처 선택
        func contactPicker(
            _ picker: CNContactPickerViewController,
            didSelect contacts: [CNContact]
        ) {
            parent.onSelect(contacts)
        }
    }
}
