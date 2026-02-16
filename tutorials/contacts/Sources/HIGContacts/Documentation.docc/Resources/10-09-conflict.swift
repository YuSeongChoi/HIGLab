import Contacts

class SyncManager {
    let store = CNContactStore()
    
    enum ConflictResolution {
        case useLocal
        case useRemote
        case merge
        case askUser
    }
    
    var conflictResolutionStrategy: ConflictResolution = .merge
    
    func resolveConflict(
        localContact: CNContact,
        remoteContact: CNContact
    ) -> CNMutableContact {
        guard let merged = localContact.mutableCopy() as? CNMutableContact else {
            fatalError("변환 실패")
        }
        
        switch conflictResolutionStrategy {
        case .useLocal:
            return merged
            
        case .useRemote:
            return remoteContact.mutableCopy() as! CNMutableContact
            
        case .merge:
            // 양쪽 데이터 병합
            // 예: 전화번호 합치기
            var phones = Set(localContact.phoneNumbers.map { $0.value.stringValue })
            for phone in remoteContact.phoneNumbers {
                if !phones.contains(phone.value.stringValue) {
                    var newPhones = merged.phoneNumbers
                    newPhones.append(phone)
                    merged.phoneNumbers = newPhones
                }
            }
            return merged
            
        case .askUser:
            // UI로 사용자에게 선택 요청
            return merged
        }
    }
}
