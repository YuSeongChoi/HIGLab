import Foundation
import Contacts

struct ContactModel: Identifiable {
    let id: String
    let fullName: String
    let phoneNumbers: [PhoneNumber]
    let emails: [String]
    let imageData: Data?
    
    struct PhoneNumber {
        let label: String
        let number: String
    }
    
    init(contact: CNContact) {
        self.id = contact.identifier
        self.fullName = CNContactFormatter.string(from: contact, style: .fullName) ?? "이름 없음"
        self.phoneNumbers = contact.phoneNumbers.map { labeled in
            let label = CNLabeledValue<NSString>.localizedString(forLabel: labeled.label ?? "")
            return PhoneNumber(label: label, number: labeled.value.stringValue)
        }
        self.emails = contact.emailAddresses.map { $0.value as String }
        self.imageData = contact.thumbnailImageData
    }
}
