import ContactsUI
import SwiftUI

struct ContactPickerView: UIViewControllerRepresentable {
    var onSelect: (CNContact) -> Void
    
    // 표시할 프로퍼티 키
    var displayedPropertyKeys: [String]?
    
    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        
        // 연락처 목록에서 표시할 정보 지정
        // 예: 이름과 전화번호만 표시
        picker.displayedPropertyKeys = displayedPropertyKeys ?? [
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactPhoneNumbersKey
        ]
        
        return picker
    }
    
    // ... 나머지 구현
}
