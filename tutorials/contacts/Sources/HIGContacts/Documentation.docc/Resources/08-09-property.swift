import ContactsUI
import SwiftUI

struct PropertyPickerView: UIViewControllerRepresentable {
    var onSelectProperty: (CNContactProperty) -> Void
    
    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        
        // 전화번호 선택 시 바로 콜백
        picker.predicateForSelectionOfProperty = NSPredicate(
            format: "key == %@",
            CNContactPhoneNumbersKey
        )
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CNContactPickerDelegate {
        let parent: PropertyPickerView
        
        init(_ parent: PropertyPickerView) {
            self.parent = parent
        }
        
        // 특정 프로퍼티(전화번호, 이메일 등) 선택
        func contactPicker(
            _ picker: CNContactPickerViewController,
            didSelect contactProperty: CNContactProperty
        ) {
            parent.onSelectProperty(contactProperty)
            
            // contactProperty.key: 프로퍼티 종류 (예: phoneNumbers)
            // contactProperty.value: 선택된 값
            // contactProperty.contact: 해당 연락처
        }
    }
}
