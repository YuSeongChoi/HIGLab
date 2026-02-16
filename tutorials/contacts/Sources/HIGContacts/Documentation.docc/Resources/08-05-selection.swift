import ContactsUI
import SwiftUI

struct ContactPickerView: UIViewControllerRepresentable {
    var onSelect: (CNContact) -> Void
    var onSelectProperty: ((CNContactProperty) -> Void)?
    
    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        
        // 특정 프로퍼티만 선택 가능하게 하려면
        // 예: 전화번호만 선택 가능
        if onSelectProperty != nil {
            picker.predicateForSelectionOfProperty = NSPredicate(
                format: "key == %@",
                CNContactPhoneNumbersKey
            )
        }
        
        return picker
    }
    
    // ... 나머지 구현
}
