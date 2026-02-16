import ContactsUI
import SwiftUI

struct ContactPickerView: UIViewControllerRepresentable {
    var onSelect: (CNContact) -> Void
    
    // 선택 가능한 연락처 필터링
    var predicateForEnabling: NSPredicate?
    var predicateForSelection: NSPredicate?
    
    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        
        // 이메일이 있는 연락처만 선택 가능
        picker.predicateForEnablingContact = NSPredicate(
            format: "emailAddresses.@count > 0"
        )
        
        // 선택 시 상세 화면 표시 여부
        // nil이면 바로 선택, predicate 있으면 상세 화면 표시
        picker.predicateForSelectionOfContact = nil
        
        return picker
    }
    
    // ... 나머지 구현
}
