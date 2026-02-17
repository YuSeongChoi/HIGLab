import Foundation

// MARK: - NFC 태그 타입

/// NFC 태그의 종류를 나타내는 열거형
enum NFCTagType: String, Codable, CaseIterable {
    case type1 = "Type 1"       // ISO 14443A (Topaz)
    case type2 = "Type 2"       // ISO 14443A (NTAG, Ultralight)
    case type3 = "Type 3"       // FeliCa (Sony)
    case type4 = "Type 4"       // ISO 14443A/B (DESFire, JCOP)
    case type5 = "Type 5"       // ISO 15693 (ICODE)
    case mifare = "MIFARE"      // NXP MIFARE Classic
    case unknown = "Unknown"    // 알 수 없는 타입
    
    /// 태그 타입에 대한 설명
    var description: String {
        switch self {
        case .type1:
            return "NFC Forum Type 1 태그 (Topaz)"
        case .type2:
            return "NFC Forum Type 2 태그 (NTAG, Ultralight)"
        case .type3:
            return "NFC Forum Type 3 태그 (FeliCa)"
        case .type4:
            return "NFC Forum Type 4 태그 (DESFire)"
        case .type5:
            return "NFC Forum Type 5 태그 (ISO 15693)"
        case .mifare:
            return "MIFARE Classic 태그"
        case .unknown:
            return "알 수 없는 태그 타입"
        }
    }
    
    /// 태그 타입을 나타내는 SF Symbol 이름
    var iconName: String {
        switch self {
        case .type1, .type2:
            return "tag.fill"
        case .type3:
            return "wave.3.right"
        case .type4:
            return "creditcard.fill"
        case .type5:
            return "barcode.viewfinder"
        case .mifare:
            return "key.fill"
        case .unknown:
            return "questionmark.circle.fill"
        }
    }
    
    /// 태그의 일반적인 메모리 크기 (바이트)
    var typicalMemorySize: String {
        switch self {
        case .type1:
            return "96 - 2,048 bytes"
        case .type2:
            return "48 - 888 bytes"
        case .type3:
            return "1 - 9 KB"
        case .type4:
            return "2 - 32 KB"
        case .type5:
            return "256 - 8,192 bytes"
        case .mifare:
            return "1 - 4 KB"
        case .unknown:
            return "알 수 없음"
        }
    }
    
    /// 태그가 쓰기 가능한지 여부 (일반적인 경우)
    var isTypicallyWritable: Bool {
        switch self {
        case .unknown:
            return false
        default:
            return true
        }
    }
}

// MARK: - NDEF 레코드 타입

/// NDEF 레코드의 TNF (Type Name Format) 값
enum TNFType: UInt8, Codable {
    case empty = 0x00           // 빈 레코드
    case wellKnown = 0x01       // NFC Forum Well-Known Type
    case media = 0x02           // MIME Media Type (RFC 2046)
    case absoluteURI = 0x03     // Absolute URI (RFC 3986)
    case external = 0x04        // NFC Forum External Type
    case unknown = 0x05         // 알 수 없는 타입
    case unchanged = 0x06       // Chunked 레코드의 연속
    case reserved = 0x07        // 예약됨
    
    /// TNF 타입에 대한 설명
    var description: String {
        switch self {
        case .empty:
            return "빈 레코드"
        case .wellKnown:
            return "Well-Known 타입"
        case .media:
            return "MIME 미디어 타입"
        case .absoluteURI:
            return "절대 URI"
        case .external:
            return "외부 타입"
        case .unknown:
            return "알 수 없음"
        case .unchanged:
            return "청크 연속"
        case .reserved:
            return "예약됨"
        }
    }
}

// MARK: - Well-Known 레코드 타입

/// NFC Forum Well-Known 레코드 타입
enum WellKnownType: String, Codable {
    case text = "T"             // 텍스트
    case uri = "U"              // URI
    case smartPoster = "Sp"     // 스마트 포스터
    case alternativeCarrier = "ac"  // 대체 캐리어
    case handoverCarrier = "Hc"     // 핸드오버 캐리어
    case handoverRequest = "Hr"     // 핸드오버 요청
    case handoverSelect = "Hs"      // 핸드오버 선택
    case signature = "Sig"          // 서명
    case unknown = ""           // 알 수 없음
    
    /// Well-Known 타입에 대한 설명
    var description: String {
        switch self {
        case .text:
            return "텍스트 레코드"
        case .uri:
            return "URI 레코드"
        case .smartPoster:
            return "스마트 포스터"
        case .alternativeCarrier:
            return "대체 캐리어"
        case .handoverCarrier:
            return "핸드오버 캐리어"
        case .handoverRequest:
            return "핸드오버 요청"
        case .handoverSelect:
            return "핸드오버 선택"
        case .signature:
            return "디지털 서명"
        case .unknown:
            return "알 수 없는 타입"
        }
    }
    
    /// 아이콘 이름
    var iconName: String {
        switch self {
        case .text:
            return "text.alignleft"
        case .uri:
            return "link"
        case .smartPoster:
            return "doc.richtext"
        case .alternativeCarrier, .handoverCarrier, .handoverRequest, .handoverSelect:
            return "arrow.triangle.swap"
        case .signature:
            return "signature"
        case .unknown:
            return "questionmark.diamond"
        }
    }
}
