import Foundation

// MARK: - NDEF 메시지 모델

/// NDEF 메시지를 나타내는 구조체
/// 하나의 NDEF 메시지는 여러 개의 NDEF 레코드로 구성됨
struct NDEFMessage: Identifiable, Codable {
    let id: UUID
    let records: [NDEFRecord]     // NDEF 레코드 배열
    let tagType: NFCTagType       // 태그 타입
    let tagIdentifier: Data?      // 태그 고유 식별자
    let isWritable: Bool          // 쓰기 가능 여부
    let capacity: Int             // 태그 용량 (바이트)
    let usedSize: Int             // 사용된 크기 (바이트)
    
    init(
        id: UUID = UUID(),
        records: [NDEFRecord],
        tagType: NFCTagType = .unknown,
        tagIdentifier: Data? = nil,
        isWritable: Bool = true,
        capacity: Int = 0,
        usedSize: Int = 0
    ) {
        self.id = id
        self.records = records
        self.tagType = tagType
        self.tagIdentifier = tagIdentifier
        self.isWritable = isWritable
        self.capacity = capacity
        self.usedSize = usedSize
    }
    
    /// 태그 식별자 문자열
    var tagIdentifierString: String {
        tagIdentifier?.hexString ?? "알 수 없음"
    }
    
    /// 사용 가능한 용량 (바이트)
    var availableCapacity: Int {
        max(0, capacity - usedSize)
    }
    
    /// 용량 사용률 (0.0 ~ 1.0)
    var usageRatio: Double {
        guard capacity > 0 else { return 0 }
        return Double(usedSize) / Double(capacity)
    }
    
    /// 메시지 요약
    var summary: String {
        if records.isEmpty {
            return "빈 태그"
        } else if records.count == 1 {
            return records[0].summary
        } else {
            return "\(records.count)개의 레코드"
        }
    }
    
    /// 첫 번째 레코드의 콘텐츠 타입
    var primaryContentType: ContentType {
        guard let firstRecord = records.first,
              let content = firstRecord.parsedContent else {
            return .empty
        }
        
        switch content {
        case .text:
            return .text
        case .uri(let uriContent):
            switch uriContent.uriType {
            case .web:
                return .url
            case .phone:
                return .phone
            case .email:
                return .email
            default:
                return .url
            }
        case .contact:
            return .contact
        case .raw:
            return .raw
        }
    }
    
    /// 콘텐츠 타입 열거형
    enum ContentType {
        case text, url, phone, email, contact, raw, empty
        
        var displayName: String {
            switch self {
            case .text: return "텍스트"
            case .url: return "URL"
            case .phone: return "전화번호"
            case .email: return "이메일"
            case .contact: return "연락처"
            case .raw: return "Raw 데이터"
            case .empty: return "빈 태그"
            }
        }
        
        var iconName: String {
            switch self {
            case .text: return "text.alignleft"
            case .url: return "globe"
            case .phone: return "phone.fill"
            case .email: return "envelope.fill"
            case .contact: return "person.crop.circle"
            case .raw: return "doc.text"
            case .empty: return "tag"
            }
        }
    }
}

// MARK: - NDEF 메시지 빌더

/// NDEF 메시지를 생성하기 위한 빌더 클래스
class NDEFMessageBuilder {
    private var records: [NDEFRecord] = []
    
    /// 텍스트 레코드 추가
    @discardableResult
    func addTextRecord(_ text: String, languageCode: String = "ko") -> Self {
        // 텍스트 레코드 페이로드 구성
        var payload = Data()
        
        // 상태 바이트: UTF-8 (비트 7 = 0), 언어 코드 길이
        let languageCodeData = languageCode.data(using: .ascii) ?? Data()
        let statusByte = UInt8(languageCodeData.count & 0x3F)
        payload.append(statusByte)
        
        // 언어 코드
        payload.append(languageCodeData)
        
        // 텍스트 데이터
        if let textData = text.data(using: .utf8) {
            payload.append(textData)
        }
        
        let record = NDEFRecord(
            tnf: .wellKnown,
            type: "T".data(using: .utf8) ?? Data(),
            payload: payload
        )
        records.append(record)
        
        return self
    }
    
    /// URI 레코드 추가
    @discardableResult
    func addURIRecord(_ uri: String) -> Self {
        var payload = Data()
        
        // URI 식별자 코드와 경로 분리
        var identifierCode: UInt8 = 0x00
        var path = uri
        
        // 알려진 스키마 확인
        let schemes: [(String, UInt8)] = [
            ("https://www.", 0x02),
            ("http://www.", 0x01),
            ("https://", 0x04),
            ("http://", 0x03),
            ("tel:", 0x05),
            ("mailto:", 0x06)
        ]
        
        for (scheme, code) in schemes {
            if uri.lowercased().hasPrefix(scheme.lowercased()) {
                identifierCode = code
                path = String(uri.dropFirst(scheme.count))
                break
            }
        }
        
        payload.append(identifierCode)
        if let pathData = path.data(using: .utf8) {
            payload.append(pathData)
        }
        
        let record = NDEFRecord(
            tnf: .wellKnown,
            type: "U".data(using: .utf8) ?? Data(),
            payload: payload
        )
        records.append(record)
        
        return self
    }
    
    /// vCard 연락처 레코드 추가
    @discardableResult
    func addContactRecord(
        name: String,
        phone: String? = nil,
        email: String? = nil,
        organization: String? = nil
    ) -> Self {
        // vCard 3.0 형식 생성
        var vCard = "BEGIN:VCARD\r\n"
        vCard += "VERSION:3.0\r\n"
        vCard += "FN:\(name)\r\n"
        
        // 이름 분리 (공백 기준)
        let nameParts = name.components(separatedBy: " ")
        if nameParts.count >= 2 {
            let lastName = nameParts.last ?? ""
            let firstName = nameParts.dropLast().joined(separator: " ")
            vCard += "N:\(lastName);\(firstName);;;\r\n"
        } else {
            vCard += "N:\(name);;;;\r\n"
        }
        
        if let phone = phone {
            vCard += "TEL:\(phone)\r\n"
        }
        if let email = email {
            vCard += "EMAIL:\(email)\r\n"
        }
        if let organization = organization {
            vCard += "ORG:\(organization)\r\n"
        }
        
        vCard += "END:VCARD"
        
        let record = NDEFRecord(
            tnf: .media,
            type: "text/vcard".data(using: .utf8) ?? Data(),
            payload: vCard.data(using: .utf8) ?? Data()
        )
        records.append(record)
        
        return self
    }
    
    /// 빌드된 레코드 배열 반환
    func build() -> [NDEFRecord] {
        return records
    }
    
    /// 빌더 초기화
    func reset() {
        records.removeAll()
    }
}

// MARK: - 미리 정의된 메시지 템플릿

extension NDEFMessageBuilder {
    /// 웹사이트 URL 메시지 생성
    static func websiteMessage(url: String) -> [NDEFRecord] {
        return NDEFMessageBuilder()
            .addURIRecord(url)
            .build()
    }
    
    /// 전화번호 메시지 생성
    static func phoneMessage(phoneNumber: String) -> [NDEFRecord] {
        let uri = phoneNumber.hasPrefix("tel:") ? phoneNumber : "tel:\(phoneNumber)"
        return NDEFMessageBuilder()
            .addURIRecord(uri)
            .build()
    }
    
    /// 이메일 메시지 생성
    static func emailMessage(email: String) -> [NDEFRecord] {
        let uri = email.hasPrefix("mailto:") ? email : "mailto:\(email)"
        return NDEFMessageBuilder()
            .addURIRecord(uri)
            .build()
    }
    
    /// 텍스트 메시지 생성
    static func textMessage(_ text: String, languageCode: String = "ko") -> [NDEFRecord] {
        return NDEFMessageBuilder()
            .addTextRecord(text, languageCode: languageCode)
            .build()
    }
    
    /// 명함 메시지 생성
    static func businessCardMessage(
        name: String,
        phone: String?,
        email: String?,
        organization: String?
    ) -> [NDEFRecord] {
        return NDEFMessageBuilder()
            .addContactRecord(
                name: name,
                phone: phone,
                email: email,
                organization: organization
            )
            .build()
    }
}
