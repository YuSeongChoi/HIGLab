import Foundation
import Contacts

// MARK: - Contact 모델
// CNContact를 앱에서 사용하기 편한 형태로 래핑한 모델
// Identifiable, Hashable 프로토콜 준수로 SwiftUI와 호환

struct Contact: Identifiable, Hashable {
    // MARK: - Properties
    
    /// 고유 식별자 (CNContact.identifier)
    let id: String
    
    /// 이름 (이름)
    var givenName: String
    
    /// 성 (성)
    var familyName: String
    
    /// 조직/회사명
    var organizationName: String
    
    /// 직함
    var jobTitle: String
    
    /// 전화번호 목록
    var phoneNumbers: [PhoneNumber]
    
    /// 이메일 목록
    var emails: [Email]
    
    /// 주소 목록
    var addresses: [PostalAddress]
    
    /// 프로필 이미지 데이터
    var imageData: Data?
    
    /// 썸네일 이미지 데이터
    var thumbnailImageData: Data?
    
    /// 메모
    var note: String
    
    /// 생일
    var birthday: DateComponents?
    
    // MARK: - Computed Properties
    
    /// 전체 이름 (성 + 이름, 한국식)
    var fullName: String {
        let name = "\(familyName)\(givenName)".trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? "(이름 없음)" : name
    }
    
    /// 표시용 이름 (이름이 있으면 이름, 없으면 조직명)
    var displayName: String {
        if !fullName.isEmpty && fullName != "(이름 없음)" {
            return fullName
        }
        if !organizationName.isEmpty {
            return organizationName
        }
        return "(이름 없음)"
    }
    
    /// 이니셜 (아바타 표시용)
    var initials: String {
        if !familyName.isEmpty {
            return String(familyName.prefix(1))
        }
        if !givenName.isEmpty {
            return String(givenName.prefix(1))
        }
        return "?"
    }
    
    /// 대표 전화번호
    var primaryPhone: String? {
        phoneNumbers.first?.number
    }
    
    /// 대표 이메일
    var primaryEmail: String? {
        emails.first?.address
    }
    
    // MARK: - Initialization
    
    /// 기본 초기화
    init(
        id: String = UUID().uuidString,
        givenName: String = "",
        familyName: String = "",
        organizationName: String = "",
        jobTitle: String = "",
        phoneNumbers: [PhoneNumber] = [],
        emails: [Email] = [],
        addresses: [PostalAddress] = [],
        imageData: Data? = nil,
        thumbnailImageData: Data? = nil,
        note: String = "",
        birthday: DateComponents? = nil
    ) {
        self.id = id
        self.givenName = givenName
        self.familyName = familyName
        self.organizationName = organizationName
        self.jobTitle = jobTitle
        self.phoneNumbers = phoneNumbers
        self.emails = emails
        self.addresses = addresses
        self.imageData = imageData
        self.thumbnailImageData = thumbnailImageData
        self.note = note
        self.birthday = birthday
    }
    
    /// CNContact로부터 초기화
    init(from cnContact: CNContact) {
        self.id = cnContact.identifier
        self.givenName = cnContact.givenName
        self.familyName = cnContact.familyName
        self.organizationName = cnContact.organizationName
        self.jobTitle = cnContact.jobTitle
        
        // 전화번호 변환
        self.phoneNumbers = cnContact.phoneNumbers.map { phoneValue in
            PhoneNumber(
                label: CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: phoneValue.label ?? ""),
                number: phoneValue.value.stringValue
            )
        }
        
        // 이메일 변환
        self.emails = cnContact.emailAddresses.map { emailValue in
            Email(
                label: CNLabeledValue<NSString>.localizedString(forLabel: emailValue.label ?? ""),
                address: emailValue.value as String
            )
        }
        
        // 주소 변환
        self.addresses = cnContact.postalAddresses.map { addressValue in
            PostalAddress(from: addressValue)
        }
        
        self.imageData = cnContact.imageData
        self.thumbnailImageData = cnContact.thumbnailImageData
        self.note = cnContact.note
        self.birthday = cnContact.birthday
    }
    
    // MARK: - Methods
    
    /// CNMutableContact로 변환
    func toCNMutableContact() -> CNMutableContact {
        let contact = CNMutableContact()
        
        contact.givenName = givenName
        contact.familyName = familyName
        contact.organizationName = organizationName
        contact.jobTitle = jobTitle
        contact.note = note
        
        // 전화번호 설정
        contact.phoneNumbers = phoneNumbers.map { phone in
            CNLabeledValue(
                label: phone.label.isEmpty ? CNLabelPhoneNumberMobile : phone.cnLabel,
                value: CNPhoneNumber(stringValue: phone.number)
            )
        }
        
        // 이메일 설정
        contact.emailAddresses = emails.map { email in
            CNLabeledValue(
                label: email.label.isEmpty ? CNLabelHome : email.cnLabel,
                value: email.address as NSString
            )
        }
        
        // 주소 설정
        contact.postalAddresses = addresses.map { address in
            address.toCNLabeledValue()
        }
        
        // 이미지 설정
        if let imageData = imageData {
            contact.imageData = imageData
        }
        
        // 생일 설정
        if let birthday = birthday {
            contact.birthday = birthday
        }
        
        return contact
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - PhoneNumber 모델
// 전화번호 정보를 저장하는 모델

struct PhoneNumber: Identifiable, Hashable {
    let id = UUID()
    
    /// 레이블 (휴대전화, 집, 직장 등)
    var label: String
    
    /// 전화번호
    var number: String
    
    /// CNLabel 변환
    var cnLabel: String {
        switch label {
        case "휴대전화", "mobile", "모바일":
            return CNLabelPhoneNumberMobile
        case "집", "home":
            return CNLabelHome
        case "직장", "work":
            return CNLabelWork
        case "iPhone":
            return CNLabelPhoneNumberiPhone
        default:
            return CNLabelOther
        }
    }
}

// MARK: - Email 모델
// 이메일 정보를 저장하는 모델

struct Email: Identifiable, Hashable {
    let id = UUID()
    
    /// 레이블 (집, 직장, 기타 등)
    var label: String
    
    /// 이메일 주소
    var address: String
    
    /// CNLabel 변환
    var cnLabel: String {
        switch label {
        case "집", "home":
            return CNLabelHome
        case "직장", "work":
            return CNLabelWork
        default:
            return CNLabelOther
        }
    }
}

// MARK: - PostalAddress 모델
// 주소 정보를 저장하는 모델

struct PostalAddress: Identifiable, Hashable {
    let id = UUID()
    
    /// 레이블 (집, 직장 등)
    var label: String
    
    /// 도로명/상세주소
    var street: String
    
    /// 시/군/구
    var city: String
    
    /// 도/주
    var state: String
    
    /// 우편번호
    var postalCode: String
    
    /// 국가
    var country: String
    
    /// 전체 주소 문자열
    var fullAddress: String {
        [street, city, state, postalCode, country]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
    
    /// CNLabeledValue로부터 초기화
    init(from labeledValue: CNLabeledValue<CNPostalAddress>) {
        self.label = CNLabeledValue<CNPostalAddress>.localizedString(forLabel: labeledValue.label ?? "")
        self.street = labeledValue.value.street
        self.city = labeledValue.value.city
        self.state = labeledValue.value.state
        self.postalCode = labeledValue.value.postalCode
        self.country = labeledValue.value.country
    }
    
    /// 기본 초기화
    init(
        label: String = "",
        street: String = "",
        city: String = "",
        state: String = "",
        postalCode: String = "",
        country: String = ""
    ) {
        self.label = label
        self.street = street
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.country = country
    }
    
    /// CNLabeledValue로 변환
    func toCNLabeledValue() -> CNLabeledValue<CNPostalAddress> {
        let address = CNMutablePostalAddress()
        address.street = street
        address.city = city
        address.state = state
        address.postalCode = postalCode
        address.country = country
        
        let cnLabel: String
        switch label {
        case "집", "home":
            cnLabel = CNLabelHome
        case "직장", "work":
            cnLabel = CNLabelWork
        default:
            cnLabel = CNLabelOther
        }
        
        return CNLabeledValue(label: cnLabel, value: address)
    }
}

// MARK: - 샘플 데이터

extension Contact {
    /// 미리보기용 샘플 연락처
    static let sample = Contact(
        givenName: "길동",
        familyName: "홍",
        organizationName: "조선기술",
        jobTitle: "의적",
        phoneNumbers: [
            PhoneNumber(label: "휴대전화", number: "010-1234-5678"),
            PhoneNumber(label: "직장", number: "02-123-4567")
        ],
        emails: [
            Email(label: "직장", address: "gildong@joseon.kr")
        ],
        note: "활빈당 창립 멤버"
    )
    
    /// 미리보기용 샘플 목록
    static let samples: [Contact] = [
        Contact(givenName: "길동", familyName: "홍", phoneNumbers: [PhoneNumber(label: "휴대전화", number: "010-1234-5678")]),
        Contact(givenName: "꺽정", familyName: "임", phoneNumbers: [PhoneNumber(label: "휴대전화", number: "010-2345-6789")]),
        Contact(givenName: "순신", familyName: "이", organizationName: "조선 수군", phoneNumbers: [PhoneNumber(label: "직장", number: "02-111-2222")]),
        Contact(givenName: "유신", familyName: "김", phoneNumbers: [PhoneNumber(label: "휴대전화", number: "010-3456-7890")])
    ]
}
