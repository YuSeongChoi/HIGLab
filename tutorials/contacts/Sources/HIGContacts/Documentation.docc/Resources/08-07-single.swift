import ContactsUI
import SwiftUI

extension ContactPickerView {
    class Coordinator: NSObject, CNContactPickerDelegate {
        let parent: ContactPickerView
        
        init(_ parent: ContactPickerView) {
            self.parent = parent
        }
        
        // 단일 연락처 선택
        func contactPicker(
            _ picker: CNContactPickerViewController,
            didSelect contact: CNContact
        ) {
            parent.onSelect(contact)
        }
        
        // 취소
        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            // 취소 처리
        }
    }
}
