import Contacts

class ContactManager {
    let store = CNContactStore()
    
    func createContact(_ contact: CNMutableContact) throws {
        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier: nil)
        
        do {
            try store.execute(saveRequest)
            print("연락처가 저장되었습니다")
        } catch let error as CNError {
            switch error.code {
            case .authorizationDenied:
                throw ContactError.unauthorized
            case .validationConfigurationError:
                throw ContactError.invalidData
            default:
                throw ContactError.saveFailed(error.localizedDescription)
            }
        }
    }
}

enum ContactError: Error {
    case unauthorized
    case invalidData
    case saveFailed(String)
}
