import Foundation
import Contacts
import Combine

// MARK: - ContactService
// CNContactStore를 사용하여 연락처 CRUD 작업을 수행하는 서비스
// ObservableObject로 구현하여 SwiftUI와 통합

@MainActor
class ContactService: ObservableObject {
    // MARK: - Published Properties
    
    /// 연락처 목록
    @Published var contacts: [Contact] = []
    
    /// 그룹 목록
    @Published var groups: [ContactGroup] = []
    
    /// 컨테이너 목록
    @Published var containers: [ContactContainer] = []
    
    /// 권한 상태
    @Published var permissionStatus: ContactPermissionStatus = .notDetermined
    
    /// 로딩 중 여부
    @Published var isLoading: Bool = false
    
    /// 에러 메시지
    @Published var errorMessage: String?
    
    /// 검색어
    @Published var searchText: String = ""
    
    // MARK: - Private Properties
    
    /// CNContactStore 인스턴스
    private let contactStore = CNContactStore()
    
    /// 검색 취소용
    private var searchCancellable: AnyCancellable?
    
    // MARK: - Computed Properties
    
    /// 필터링된 연락처 목록
    var filteredContacts: [Contact] {
        guard !searchText.isEmpty else { return contacts }
        
        let query = searchText.lowercased()
        return contacts.filter { contact in
            contact.fullName.lowercased().contains(query) ||
            contact.organizationName.lowercased().contains(query) ||
            contact.phoneNumbers.contains { $0.number.contains(query) } ||
            contact.emails.contains { $0.address.lowercased().contains(query) }
        }
    }
    
    /// 초성으로 그룹화된 연락처
    var groupedContacts: [(String, [Contact])] {
        let grouped = Dictionary(grouping: filteredContacts) { contact -> String in
            guard let firstChar = contact.familyName.first ?? contact.givenName.first else {
                return "#"
            }
            
            // 한글 초성 추출
            let scalar = firstChar.unicodeScalars.first!.value
            if scalar >= 0xAC00 && scalar <= 0xD7A3 {
                // 한글 완성형 범위
                let index = (scalar - 0xAC00) / 28 / 21
                let chosung = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
                return chosung[Int(index)]
            } else if firstChar.isLetter {
                return String(firstChar).uppercased()
            } else {
                return "#"
            }
        }
        
        return grouped.sorted { $0.key < $1.key }
    }
    
    // MARK: - Initialization
    
    init() {
        checkPermissionStatus()
        setupSearchDebounce()
    }
    
    // MARK: - Private Methods
    
    /// 검색 디바운스 설정
    private func setupSearchDebounce() {
        searchCancellable = $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                // 필터링은 computed property에서 자동 처리
                self?.objectWillChange.send()
            }
    }
    
    // MARK: - Permission Methods
    
    /// 현재 권한 상태 확인
    func checkPermissionStatus() {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        permissionStatus = ContactPermissionStatus(from: status)
    }
    
    /// 연락처 접근 권한 요청
    func requestAccess() {
        Task {
            do {
                let granted = try await contactStore.requestAccess(for: .contacts)
                
                if granted {
                    permissionStatus = .authorized
                    await fetchContacts()
                    await fetchGroups()
                    await fetchContainers()
                } else {
                    permissionStatus = .denied
                }
            } catch {
                permissionStatus = .denied
                errorMessage = "권한 요청 중 오류 발생: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Fetch Methods
    
    /// 모든 연락처 가져오기
    func fetchContacts() async {
        guard permissionStatus.isAccessible else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            var fetchedContacts: [Contact] = []
            
            let request = CNContactFetchRequest(keysToFetch: ContactFetchKeys.detailed)
            request.sortOrder = .familyName
            
            try contactStore.enumerateContacts(with: request) { cnContact, _ in
                let contact = Contact(from: cnContact)
                fetchedContacts.append(contact)
            }
            
            contacts = fetchedContacts
            isLoading = false
        } catch {
            errorMessage = "연락처를 가져오는 중 오류 발생: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// 특정 연락처 상세 정보 가져오기
    func fetchContact(identifier: String) async -> Contact? {
        guard permissionStatus.isAccessible else { return nil }
        
        do {
            let cnContact = try contactStore.unifiedContact(
                withIdentifier: identifier,
                keysToFetch: ContactFetchKeys.detailed
            )
            return Contact(from: cnContact)
        } catch {
            errorMessage = "연락처 상세 정보를 가져오는 중 오류 발생: \(error.localizedDescription)"
            return nil
        }
    }
    
    /// 연락처 검색
    func searchContacts(query: String) async -> [Contact] {
        guard permissionStatus.isAccessible, !query.isEmpty else { return [] }
        
        do {
            let predicate = CNContact.predicateForContacts(matchingName: query)
            let cnContacts = try contactStore.unifiedContacts(
                matching: predicate,
                keysToFetch: ContactFetchKeys.basic
            )
            
            return cnContacts.map { Contact(from: $0) }
        } catch {
            errorMessage = "연락처 검색 중 오류 발생: \(error.localizedDescription)"
            return []
        }
    }
    
    // MARK: - CRUD Methods
    
    /// 새 연락처 추가
    func addContact(_ contact: Contact) async -> Bool {
        guard permissionStatus.isAccessible else {
            errorMessage = "연락처 접근 권한이 없습니다."
            return false
        }
        
        do {
            let mutableContact = contact.toCNMutableContact()
            let saveRequest = CNSaveRequest()
            saveRequest.add(mutableContact, toContainerWithIdentifier: nil)
            
            try contactStore.execute(saveRequest)
            
            // 목록 갱신
            await fetchContacts()
            return true
        } catch {
            errorMessage = "연락처 추가 중 오류 발생: \(error.localizedDescription)"
            return false
        }
    }
    
    /// 연락처 수정
    func updateContact(_ contact: Contact) async -> Bool {
        guard permissionStatus.isAccessible else {
            errorMessage = "연락처 접근 권한이 없습니다."
            return false
        }
        
        do {
            // 기존 연락처 가져오기
            let cnContact = try contactStore.unifiedContact(
                withIdentifier: contact.id,
                keysToFetch: ContactFetchKeys.detailed
            )
            
            // 수정 가능한 복사본 생성
            guard let mutableContact = cnContact.mutableCopy() as? CNMutableContact else {
                errorMessage = "연락처를 수정할 수 없습니다."
                return false
            }
            
            // 필드 업데이트
            mutableContact.givenName = contact.givenName
            mutableContact.familyName = contact.familyName
            mutableContact.organizationName = contact.organizationName
            mutableContact.jobTitle = contact.jobTitle
            mutableContact.note = contact.note
            
            // 전화번호 업데이트
            mutableContact.phoneNumbers = contact.phoneNumbers.map { phone in
                CNLabeledValue(
                    label: phone.cnLabel,
                    value: CNPhoneNumber(stringValue: phone.number)
                )
            }
            
            // 이메일 업데이트
            mutableContact.emailAddresses = contact.emails.map { email in
                CNLabeledValue(
                    label: email.cnLabel,
                    value: email.address as NSString
                )
            }
            
            // 주소 업데이트
            mutableContact.postalAddresses = contact.addresses.map { address in
                address.toCNLabeledValue()
            }
            
            // 이미지 업데이트
            if let imageData = contact.imageData {
                mutableContact.imageData = imageData
            }
            
            // 생일 업데이트
            mutableContact.birthday = contact.birthday
            
            // 저장
            let saveRequest = CNSaveRequest()
            saveRequest.update(mutableContact)
            
            try contactStore.execute(saveRequest)
            
            // 목록 갱신
            await fetchContacts()
            return true
        } catch {
            errorMessage = "연락처 수정 중 오류 발생: \(error.localizedDescription)"
            return false
        }
    }
    
    /// 연락처 삭제
    func deleteContact(_ contact: Contact) async -> Bool {
        guard permissionStatus.isAccessible else {
            errorMessage = "연락처 접근 권한이 없습니다."
            return false
        }
        
        do {
            let cnContact = try contactStore.unifiedContact(
                withIdentifier: contact.id,
                keysToFetch: [CNContactIdentifierKey as CNKeyDescriptor]
            )
            
            guard let mutableContact = cnContact.mutableCopy() as? CNMutableContact else {
                errorMessage = "연락처를 삭제할 수 없습니다."
                return false
            }
            
            let saveRequest = CNSaveRequest()
            saveRequest.delete(mutableContact)
            
            try contactStore.execute(saveRequest)
            
            // 목록 갱신
            await fetchContacts()
            return true
        } catch {
            errorMessage = "연락처 삭제 중 오류 발생: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - Group Methods
    
    /// 모든 그룹 가져오기
    func fetchGroups() async {
        guard permissionStatus.isAccessible else { return }
        
        do {
            let cnGroups = try contactStore.groups(matching: nil)
            
            groups = cnGroups.map { cnGroup in
                // 그룹 멤버 수 계산
                let predicate = CNContact.predicateForContactsInGroup(withIdentifier: cnGroup.identifier)
                let memberCount = (try? contactStore.unifiedContacts(
                    matching: predicate,
                    keysToFetch: [CNContactIdentifierKey as CNKeyDescriptor]
                ).count) ?? 0
                
                return ContactGroup(from: cnGroup, memberCount: memberCount)
            }
        } catch {
            errorMessage = "그룹을 가져오는 중 오류 발생: \(error.localizedDescription)"
        }
    }
    
    /// 새 그룹 추가
    func addGroup(name: String, containerIdentifier: String? = nil) async -> Bool {
        guard permissionStatus.isAccessible else {
            errorMessage = "연락처 접근 권한이 없습니다."
            return false
        }
        
        do {
            let group = CNMutableGroup()
            group.name = name
            
            let saveRequest = CNSaveRequest()
            saveRequest.add(group, toContainerWithIdentifier: containerIdentifier)
            
            try contactStore.execute(saveRequest)
            
            await fetchGroups()
            return true
        } catch {
            errorMessage = "그룹 추가 중 오류 발생: \(error.localizedDescription)"
            return false
        }
    }
    
    /// 그룹 이름 수정
    func updateGroup(_ group: ContactGroup, newName: String) async -> Bool {
        guard permissionStatus.isAccessible else {
            errorMessage = "연락처 접근 권한이 없습니다."
            return false
        }
        
        do {
            let cnGroups = try contactStore.groups(matching: CNGroup.predicateForGroups(withIdentifiers: [group.id]))
            
            guard let cnGroup = cnGroups.first,
                  let mutableGroup = cnGroup.mutableCopy() as? CNMutableGroup else {
                errorMessage = "그룹을 찾을 수 없습니다."
                return false
            }
            
            mutableGroup.name = newName
            
            let saveRequest = CNSaveRequest()
            saveRequest.update(mutableGroup)
            
            try contactStore.execute(saveRequest)
            
            await fetchGroups()
            return true
        } catch {
            errorMessage = "그룹 수정 중 오류 발생: \(error.localizedDescription)"
            return false
        }
    }
    
    /// 그룹 삭제
    func deleteGroup(_ group: ContactGroup) async -> Bool {
        guard permissionStatus.isAccessible else {
            errorMessage = "연락처 접근 권한이 없습니다."
            return false
        }
        
        do {
            let cnGroups = try contactStore.groups(matching: CNGroup.predicateForGroups(withIdentifiers: [group.id]))
            
            guard let cnGroup = cnGroups.first,
                  let mutableGroup = cnGroup.mutableCopy() as? CNMutableGroup else {
                errorMessage = "그룹을 찾을 수 없습니다."
                return false
            }
            
            let saveRequest = CNSaveRequest()
            saveRequest.delete(mutableGroup)
            
            try contactStore.execute(saveRequest)
            
            await fetchGroups()
            return true
        } catch {
            errorMessage = "그룹 삭제 중 오류 발생: \(error.localizedDescription)"
            return false
        }
    }
    
    /// 그룹에 연락처 추가
    func addContact(_ contact: Contact, toGroup group: ContactGroup) async -> Bool {
        guard permissionStatus.isAccessible else {
            errorMessage = "연락처 접근 권한이 없습니다."
            return false
        }
        
        do {
            let cnContact = try contactStore.unifiedContact(
                withIdentifier: contact.id,
                keysToFetch: [CNContactIdentifierKey as CNKeyDescriptor]
            )
            
            let cnGroups = try contactStore.groups(matching: CNGroup.predicateForGroups(withIdentifiers: [group.id]))
            
            guard let cnGroup = cnGroups.first else {
                errorMessage = "그룹을 찾을 수 없습니다."
                return false
            }
            
            let saveRequest = CNSaveRequest()
            saveRequest.addMember(cnContact, to: cnGroup)
            
            try contactStore.execute(saveRequest)
            
            await fetchGroups()
            return true
        } catch {
            errorMessage = "연락처를 그룹에 추가하는 중 오류 발생: \(error.localizedDescription)"
            return false
        }
    }
    
    /// 그룹에서 연락처 제거
    func removeContact(_ contact: Contact, fromGroup group: ContactGroup) async -> Bool {
        guard permissionStatus.isAccessible else {
            errorMessage = "연락처 접근 권한이 없습니다."
            return false
        }
        
        do {
            let cnContact = try contactStore.unifiedContact(
                withIdentifier: contact.id,
                keysToFetch: [CNContactIdentifierKey as CNKeyDescriptor]
            )
            
            let cnGroups = try contactStore.groups(matching: CNGroup.predicateForGroups(withIdentifiers: [group.id]))
            
            guard let cnGroup = cnGroups.first else {
                errorMessage = "그룹을 찾을 수 없습니다."
                return false
            }
            
            let saveRequest = CNSaveRequest()
            saveRequest.removeMember(cnContact, from: cnGroup)
            
            try contactStore.execute(saveRequest)
            
            await fetchGroups()
            return true
        } catch {
            errorMessage = "연락처를 그룹에서 제거하는 중 오류 발생: \(error.localizedDescription)"
            return false
        }
    }
    
    /// 그룹에 속한 연락처 목록 가져오기
    func fetchContactsInGroup(_ group: ContactGroup) async -> [Contact] {
        guard permissionStatus.isAccessible else { return [] }
        
        do {
            let predicate = CNContact.predicateForContactsInGroup(withIdentifier: group.id)
            let cnContacts = try contactStore.unifiedContacts(
                matching: predicate,
                keysToFetch: ContactFetchKeys.basic
            )
            
            return cnContacts.map { Contact(from: $0) }
        } catch {
            errorMessage = "그룹 연락처를 가져오는 중 오류 발생: \(error.localizedDescription)"
            return []
        }
    }
    
    // MARK: - Container Methods
    
    /// 모든 컨테이너 가져오기
    func fetchContainers() async {
        guard permissionStatus.isAccessible else { return }
        
        do {
            let cnContainers = try contactStore.containers(matching: nil)
            containers = cnContainers.map { ContactContainer(from: $0) }
        } catch {
            errorMessage = "컨테이너를 가져오는 중 오류 발생: \(error.localizedDescription)"
        }
    }
    
    /// 기본 컨테이너 ID 가져오기
    func defaultContainerIdentifier() -> String? {
        try? contactStore.defaultContainerIdentifier()
    }
    
    // MARK: - Utility Methods
    
    /// 에러 메시지 초기화
    func clearError() {
        errorMessage = nil
    }
    
    /// 데이터 새로고침
    func refresh() async {
        await fetchContacts()
        await fetchGroups()
        await fetchContainers()
    }
}
