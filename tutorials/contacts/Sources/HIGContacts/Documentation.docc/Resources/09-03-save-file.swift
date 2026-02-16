import Contacts
import Foundation

class VCardManager {
    func saveVCardToFile(contacts: [CNContact], filename: String) throws -> URL {
        let vCardData = try CNContactVCardSerialization.data(with: contacts)
        
        // 임시 디렉토리에 파일 저장
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent("\(filename).vcf")
        
        try vCardData.write(to: fileURL)
        
        return fileURL
    }
    
    func saveVCardToDocuments(contacts: [CNContact], filename: String) throws -> URL {
        let vCardData = try CNContactVCardSerialization.data(with: contacts)
        
        let documentsURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        
        let fileURL = documentsURL.appendingPathComponent("\(filename).vcf")
        try vCardData.write(to: fileURL)
        
        return fileURL
    }
}
