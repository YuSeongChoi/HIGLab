import Contacts

class VCardManager {
    func exportToVCard(contact: CNContact) throws -> Data {
        // 단일 연락처를 vCard 데이터로 변환
        let vCardData = try CNContactVCardSerialization.data(with: [contact])
        return vCardData
    }
    
    func exportToVCardString(contact: CNContact) throws -> String {
        let data = try exportToVCard(contact: contact)
        return String(data: data, encoding: .utf8) ?? ""
    }
}
