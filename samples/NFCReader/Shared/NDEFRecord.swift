import Foundation

// MARK: - NDEF 레코드 모델

/// NDEF 레코드를 나타내는 구조체
struct NDEFRecord: Identifiable, Codable {
    let id: UUID
    let tnf: TNFType               // Type Name Format
    let type: Data                  // 레코드 타입
    let identifier: Data            // 레코드 식별자
    let payload: Data               // 페이로드 데이터
    let parsedContent: ParsedContent?  // 파싱된 콘텐츠
    
    init(
        id: UUID = UUID(),
        tnf: TNFType,
        type: Data,
        identifier: Data = Data(),
        payload: Data
    ) {
        self.id = id
        self.tnf = tnf
        self.type = type
        self.identifier = identifier
        self.payload = payload
        self.parsedContent = NDEFRecord.parsePayload(tnf: tnf, type: type, payload: payload)
    }
    
    /// 레코드의 타입 문자열
    var typeString: String {
        String(data: type, encoding: .utf8) ?? type.hexString
    }
    
    /// 레코드의 요약 설명
    var summary: String {
        if let content = parsedContent {
            return content.summary
        }
        return "Raw Data: \(payload.count) bytes"
    }
}

// MARK: - 파싱된 콘텐츠

/// 파싱된 NDEF 레코드 콘텐츠
enum ParsedContent: Codable {
    case text(TextContent)
    case uri(URIContent)
    case contact(ContactContent)
    case raw(RawContent)
    
    var summary: String {
        switch self {
        case .text(let content):
            return content.text
        case .uri(let content):
            return content.uri
        case .contact(let content):
            return content.displayName
        case .raw(let content):
            return "Raw: \(content.data.count) bytes"
        }
    }
    
    var iconName: String {
        switch self {
        case .text:
            return "text.alignleft"
        case .uri:
            return "link"
        case .contact:
            return "person.crop.circle"
        case .raw:
            return "doc.text"
        }
    }
}

// MARK: - 텍스트 콘텐츠

/// 텍스트 레코드 콘텐츠
struct TextContent: Codable {
    let text: String           // 텍스트 내용
    let languageCode: String   // 언어 코드 (예: "ko", "en")
    let encoding: TextEncoding // 인코딩 타입
    
    enum TextEncoding: String, Codable {
        case utf8 = "UTF-8"
        case utf16 = "UTF-16"
    }
}

// MARK: - URI 콘텐츠

/// URI 레코드 콘텐츠
struct URIContent: Codable {
    let uri: String            // 전체 URI
    let scheme: String         // URI 스키마 (예: "https://")
    let path: String           // 스키마를 제외한 경로
    
    /// URI 타입 판별
    var uriType: URIType {
        if uri.hasPrefix("tel:") {
            return .phone
        } else if uri.hasPrefix("mailto:") {
            return .email
        } else if uri.hasPrefix("http://") || uri.hasPrefix("https://") {
            return .web
        } else if uri.hasPrefix("geo:") {
            return .location
        } else if uri.hasPrefix("sms:") {
            return .sms
        } else {
            return .other
        }
    }
    
    enum URIType {
        case web, phone, email, sms, location, other
        
        var iconName: String {
            switch self {
            case .web:
                return "globe"
            case .phone:
                return "phone.fill"
            case .email:
                return "envelope.fill"
            case .sms:
                return "message.fill"
            case .location:
                return "location.fill"
            case .other:
                return "link"
            }
        }
    }
}

// MARK: - 연락처 콘텐츠

/// vCard 연락처 콘텐츠
struct ContactContent: Codable {
    let displayName: String     // 표시 이름
    let firstName: String?      // 이름
    let lastName: String?       // 성
    let phone: String?          // 전화번호
    let email: String?          // 이메일
    let organization: String?   // 조직
    let title: String?          // 직함
    let url: String?            // 웹사이트
    let rawVCard: String        // 원본 vCard 데이터
}

// MARK: - Raw 콘텐츠

/// 파싱되지 않은 원본 콘텐츠
struct RawContent: Codable {
    let data: Data
    let mimeType: String?
    
    var hexString: String {
        data.hexString
    }
}

// MARK: - 페이로드 파싱

extension NDEFRecord {
    /// 페이로드를 파싱하여 적절한 콘텐츠 타입으로 변환
    static func parsePayload(tnf: TNFType, type: Data, payload: Data) -> ParsedContent? {
        guard !payload.isEmpty else { return nil }
        
        let typeString = String(data: type, encoding: .utf8) ?? ""
        
        switch tnf {
        case .wellKnown:
            return parseWellKnownType(typeString: typeString, payload: payload)
        case .media:
            return parseMediaType(typeString: typeString, payload: payload)
        case .absoluteURI:
            let uri = String(data: payload, encoding: .utf8) ?? ""
            return .uri(URIContent(uri: uri, scheme: "", path: uri))
        default:
            return .raw(RawContent(data: payload, mimeType: typeString.isEmpty ? nil : typeString))
        }
    }
    
    /// Well-Known 타입 페이로드 파싱
    private static func parseWellKnownType(typeString: String, payload: Data) -> ParsedContent? {
        guard let wellKnownType = WellKnownType(rawValue: typeString) else {
            return .raw(RawContent(data: payload, mimeType: nil))
        }
        
        switch wellKnownType {
        case .text:
            return parseTextPayload(payload)
        case .uri:
            return parseURIPayload(payload)
        default:
            return .raw(RawContent(data: payload, mimeType: nil))
        }
    }
    
    /// 텍스트 페이로드 파싱
    private static func parseTextPayload(_ payload: Data) -> ParsedContent? {
        guard payload.count > 1 else { return nil }
        
        // 첫 번째 바이트: 상태 바이트
        let statusByte = payload[0]
        let isUTF16 = (statusByte & 0x80) != 0  // 비트 7: 인코딩
        let languageCodeLength = Int(statusByte & 0x3F)  // 비트 0-5: 언어 코드 길이
        
        guard payload.count > languageCodeLength + 1 else { return nil }
        
        // 언어 코드 추출
        let languageCodeData = payload[1..<(1 + languageCodeLength)]
        let languageCode = String(data: Data(languageCodeData), encoding: .ascii) ?? "unknown"
        
        // 텍스트 추출
        let textData = payload[(1 + languageCodeLength)...]
        let encoding: String.Encoding = isUTF16 ? .utf16 : .utf8
        let text = String(data: Data(textData), encoding: encoding) ?? ""
        
        return .text(TextContent(
            text: text,
            languageCode: languageCode,
            encoding: isUTF16 ? .utf16 : .utf8
        ))
    }
    
    /// URI 페이로드 파싱
    private static func parseURIPayload(_ payload: Data) -> ParsedContent? {
        guard !payload.isEmpty else { return nil }
        
        // 첫 번째 바이트: URI 식별자 코드
        let identifierCode = payload[0]
        let scheme = URIPrefixes.prefix(for: identifierCode)
        
        // 나머지 데이터: URI 경로
        let pathData = payload[1...]
        let path = String(data: Data(pathData), encoding: .utf8) ?? ""
        let fullURI = scheme + path
        
        return .uri(URIContent(uri: fullURI, scheme: scheme, path: path))
    }
    
    /// MIME 미디어 타입 파싱
    private static func parseMediaType(typeString: String, payload: Data) -> ParsedContent? {
        // vCard 파싱
        if typeString.lowercased().contains("vcard") {
            return parseVCard(payload)
        }
        
        return .raw(RawContent(data: payload, mimeType: typeString))
    }
    
    /// vCard 파싱
    private static func parseVCard(_ payload: Data) -> ParsedContent? {
        guard let vCardString = String(data: payload, encoding: .utf8) else { return nil }
        
        var firstName: String?
        var lastName: String?
        var phone: String?
        var email: String?
        var organization: String?
        var title: String?
        var url: String?
        var displayName = ""
        
        // vCard 라인별 파싱
        let lines = vCardString.components(separatedBy: .newlines)
        for line in lines {
            let parts = line.components(separatedBy: ":")
            guard parts.count >= 2 else { continue }
            
            let key = parts[0].uppercased()
            let value = parts.dropFirst().joined(separator: ":")
            
            if key.hasPrefix("FN") {
                displayName = value
            } else if key.hasPrefix("N") {
                let nameParts = value.components(separatedBy: ";")
                if nameParts.count >= 2 {
                    lastName = nameParts[0].isEmpty ? nil : nameParts[0]
                    firstName = nameParts[1].isEmpty ? nil : nameParts[1]
                }
            } else if key.hasPrefix("TEL") {
                phone = value
            } else if key.hasPrefix("EMAIL") {
                email = value
            } else if key.hasPrefix("ORG") {
                organization = value
            } else if key.hasPrefix("TITLE") {
                title = value
            } else if key.hasPrefix("URL") {
                url = value
            }
        }
        
        // 표시 이름이 없으면 이름/성으로 조합
        if displayName.isEmpty {
            displayName = [firstName, lastName].compactMap { $0 }.joined(separator: " ")
        }
        
        return .contact(ContactContent(
            displayName: displayName,
            firstName: firstName,
            lastName: lastName,
            phone: phone,
            email: email,
            organization: organization,
            title: title,
            url: url,
            rawVCard: vCardString
        ))
    }
}

// MARK: - URI 접두사 매핑

/// NFC Forum URI 식별자 코드에 따른 접두사 매핑
enum URIPrefixes {
    static func prefix(for code: UInt8) -> String {
        switch code {
        case 0x00: return ""
        case 0x01: return "http://www."
        case 0x02: return "https://www."
        case 0x03: return "http://"
        case 0x04: return "https://"
        case 0x05: return "tel:"
        case 0x06: return "mailto:"
        case 0x07: return "ftp://anonymous:anonymous@"
        case 0x08: return "ftp://ftp."
        case 0x09: return "ftps://"
        case 0x0A: return "sftp://"
        case 0x0B: return "smb://"
        case 0x0C: return "nfs://"
        case 0x0D: return "ftp://"
        case 0x0E: return "dav://"
        case 0x0F: return "news:"
        case 0x10: return "telnet://"
        case 0x11: return "imap:"
        case 0x12: return "rtsp://"
        case 0x13: return "urn:"
        case 0x14: return "pop:"
        case 0x15: return "sip:"
        case 0x16: return "sips:"
        case 0x17: return "tftp:"
        case 0x18: return "btspp://"
        case 0x19: return "btl2cap://"
        case 0x1A: return "btgoep://"
        case 0x1B: return "tcpobex://"
        case 0x1C: return "irdaobex://"
        case 0x1D: return "file://"
        case 0x1E: return "urn:epc:id:"
        case 0x1F: return "urn:epc:tag:"
        case 0x20: return "urn:epc:pat:"
        case 0x21: return "urn:epc:raw:"
        case 0x22: return "urn:epc:"
        case 0x23: return "urn:nfc:"
        default: return ""
        }
    }
    
    /// 스키마에 해당하는 URI 코드 반환
    static func code(for scheme: String) -> UInt8 {
        switch scheme.lowercased() {
        case "http://www.": return 0x01
        case "https://www.": return 0x02
        case "http://": return 0x03
        case "https://": return 0x04
        case "tel:": return 0x05
        case "mailto:": return 0x06
        default: return 0x00
        }
    }
}

// MARK: - Data Extension

extension Data {
    /// Data를 16진수 문자열로 변환
    var hexString: String {
        map { String(format: "%02X", $0) }.joined(separator: " ")
    }
}
