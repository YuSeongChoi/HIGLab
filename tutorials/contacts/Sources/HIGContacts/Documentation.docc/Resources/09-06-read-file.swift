import Contacts
import Foundation

class VCardManager {
    func readVCardFile(at url: URL) throws -> [CNContact] {
        // 보안 스코프 리소스 접근
        guard url.startAccessingSecurityScopedResource() else {
            throw VCardError.readFailed
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        // 파일 읽기
        let data = try Data(contentsOf: url)
        
        // vCard 파싱
        let contacts = try CNContactVCardSerialization.contacts(with: data)
        
        return contacts
    }
}
