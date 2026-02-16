import Contacts

class VCardManager {
    func parseVCard(data: Data) throws -> [CNContact] {
        // vCard 데이터에서 연락처 배열로 변환
        let contacts = try CNContactVCardSerialization.contacts(with: data)
        return contacts
    }
    
    func parseVCardString(_ string: String) throws -> [CNContact] {
        guard let data = string.data(using: .utf8) else {
            throw VCardError.invalidData
        }
        return try parseVCard(data: data)
    }
}

enum VCardError: Error {
    case invalidData
    case readFailed
    case importFailed
}
