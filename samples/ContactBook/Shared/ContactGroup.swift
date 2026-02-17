import Foundation
import Contacts

// MARK: - ContactGroup 모델
// CNGroup을 앱에서 사용하기 편한 형태로 래핑한 모델
// 연락처 그룹 관리 기능 지원

struct ContactGroup: Identifiable, Hashable {
    // MARK: - Properties
    
    /// 고유 식별자 (CNGroup.identifier)
    let id: String
    
    /// 그룹 이름
    var name: String
    
    /// 그룹에 속한 연락처 수
    var memberCount: Int
    
    /// 그룹에 속한 연락처 ID 목록
    var memberIdentifiers: [String]
    
    // MARK: - Computed Properties
    
    /// 멤버 수 표시 문자열
    var memberCountText: String {
        "\(memberCount)명"
    }
    
    // MARK: - Initialization
    
    /// 기본 초기화
    init(
        id: String = UUID().uuidString,
        name: String,
        memberCount: Int = 0,
        memberIdentifiers: [String] = []
    ) {
        self.id = id
        self.name = name
        self.memberCount = memberCount
        self.memberIdentifiers = memberIdentifiers
    }
    
    /// CNGroup으로부터 초기화
    init(from cnGroup: CNGroup, memberCount: Int = 0, memberIdentifiers: [String] = []) {
        self.id = cnGroup.identifier
        self.name = cnGroup.name
        self.memberCount = memberCount
        self.memberIdentifiers = memberIdentifiers
    }
}

// MARK: - 샘플 데이터

extension ContactGroup {
    /// 미리보기용 샘플 그룹
    static let sample = ContactGroup(
        name: "가족",
        memberCount: 5
    )
    
    /// 미리보기용 샘플 목록
    static let samples: [ContactGroup] = [
        ContactGroup(name: "가족", memberCount: 5),
        ContactGroup(name: "친구", memberCount: 12),
        ContactGroup(name: "직장", memberCount: 8),
        ContactGroup(name: "동호회", memberCount: 15)
    ]
}

// MARK: - ContactContainer 모델
// CNContainer (연락처 저장소 - iCloud, Local 등)를 래핑

struct ContactContainer: Identifiable, Hashable {
    // MARK: - Properties
    
    /// 고유 식별자
    let id: String
    
    /// 컨테이너 이름
    var name: String
    
    /// 컨테이너 타입
    var type: ContainerType
    
    // MARK: - ContainerType
    
    enum ContainerType: String {
        case local = "로컬"
        case exchange = "Exchange"
        case cardDAV = "CardDAV"
        case unassigned = "기타"
        
        init(from cnType: CNContainerType) {
            switch cnType {
            case .local:
                self = .local
            case .exchange:
                self = .exchange
            case .cardDAV:
                self = .cardDAV
            @unknown default:
                self = .unassigned
            }
        }
    }
    
    // MARK: - Initialization
    
    init(id: String, name: String, type: ContainerType) {
        self.id = id
        self.name = name
        self.type = type
    }
    
    init(from cnContainer: CNContainer) {
        self.id = cnContainer.identifier
        self.name = cnContainer.name
        self.type = ContainerType(from: cnContainer.type)
    }
}

// MARK: - ContactPermissionStatus
// 연락처 접근 권한 상태를 나타내는 열거형

enum ContactPermissionStatus {
    /// 권한이 허용됨
    case authorized
    
    /// 권한이 거부됨
    case denied
    
    /// 권한 요청 전 (미결정)
    case notDetermined
    
    /// 제한됨 (부모 제어 등)
    case restricted
    
    /// 제한된 접근만 허용 (iOS 18+)
    case limited
    
    /// CNAuthorizationStatus로부터 변환
    init(from status: CNAuthorizationStatus) {
        switch status {
        case .authorized:
            self = .authorized
        case .denied:
            self = .denied
        case .notDetermined:
            self = .notDetermined
        case .restricted:
            self = .restricted
        case .limited:
            self = .limited
        @unknown default:
            self = .denied
        }
    }
    
    /// 사용자에게 표시할 메시지
    var message: String {
        switch self {
        case .authorized:
            return "연락처에 접근할 수 있습니다."
        case .denied:
            return "연락처 접근 권한이 거부되었습니다.\n설정에서 권한을 허용해주세요."
        case .notDetermined:
            return "연락처 접근 권한을 요청합니다."
        case .restricted:
            return "연락처 접근이 제한되어 있습니다."
        case .limited:
            return "일부 연락처만 접근할 수 있습니다."
        }
    }
    
    /// 접근 가능 여부
    var isAccessible: Bool {
        switch self {
        case .authorized, .limited:
            return true
        default:
            return false
        }
    }
}

// MARK: - ContactSortOrder
// 연락처 정렬 순서

enum ContactSortOrder: String, CaseIterable, Identifiable {
    case familyName = "성"
    case givenName = "이름"
    
    var id: String { rawValue }
    
    /// CNContactSortOrder로 변환
    var cnSortOrder: CNContactSortOrder {
        switch self {
        case .familyName:
            return .familyName
        case .givenName:
            return .givenName
        }
    }
}

// MARK: - ContactFetchKeys
// 연락처 가져오기 시 필요한 키 집합

struct ContactFetchKeys {
    /// 기본 키 (목록 표시용)
    static let basic: [CNKeyDescriptor] = [
        CNContactIdentifierKey as CNKeyDescriptor,
        CNContactGivenNameKey as CNKeyDescriptor,
        CNContactFamilyNameKey as CNKeyDescriptor,
        CNContactOrganizationNameKey as CNKeyDescriptor,
        CNContactPhoneNumbersKey as CNKeyDescriptor,
        CNContactThumbnailImageDataKey as CNKeyDescriptor
    ]
    
    /// 상세 키 (상세 화면용)
    static let detailed: [CNKeyDescriptor] = [
        CNContactIdentifierKey as CNKeyDescriptor,
        CNContactGivenNameKey as CNKeyDescriptor,
        CNContactFamilyNameKey as CNKeyDescriptor,
        CNContactOrganizationNameKey as CNKeyDescriptor,
        CNContactJobTitleKey as CNKeyDescriptor,
        CNContactPhoneNumbersKey as CNKeyDescriptor,
        CNContactEmailAddressesKey as CNKeyDescriptor,
        CNContactPostalAddressesKey as CNKeyDescriptor,
        CNContactImageDataKey as CNKeyDescriptor,
        CNContactThumbnailImageDataKey as CNKeyDescriptor,
        CNContactNoteKey as CNKeyDescriptor,
        CNContactBirthdayKey as CNKeyDescriptor
    ]
    
    /// 모든 키
    static let all: [CNKeyDescriptor] = [
        CNContactIdentifierKey as CNKeyDescriptor,
        CNContactGivenNameKey as CNKeyDescriptor,
        CNContactFamilyNameKey as CNKeyDescriptor,
        CNContactMiddleNameKey as CNKeyDescriptor,
        CNContactNamePrefixKey as CNKeyDescriptor,
        CNContactNameSuffixKey as CNKeyDescriptor,
        CNContactNicknameKey as CNKeyDescriptor,
        CNContactOrganizationNameKey as CNKeyDescriptor,
        CNContactDepartmentNameKey as CNKeyDescriptor,
        CNContactJobTitleKey as CNKeyDescriptor,
        CNContactPhoneNumbersKey as CNKeyDescriptor,
        CNContactEmailAddressesKey as CNKeyDescriptor,
        CNContactPostalAddressesKey as CNKeyDescriptor,
        CNContactUrlAddressesKey as CNKeyDescriptor,
        CNContactSocialProfilesKey as CNKeyDescriptor,
        CNContactInstantMessageAddressesKey as CNKeyDescriptor,
        CNContactImageDataKey as CNKeyDescriptor,
        CNContactThumbnailImageDataKey as CNKeyDescriptor,
        CNContactImageDataAvailableKey as CNKeyDescriptor,
        CNContactNoteKey as CNKeyDescriptor,
        CNContactBirthdayKey as CNKeyDescriptor,
        CNContactDatesKey as CNKeyDescriptor,
        CNContactRelationsKey as CNKeyDescriptor,
        CNContactTypeKey as CNKeyDescriptor
    ]
}
