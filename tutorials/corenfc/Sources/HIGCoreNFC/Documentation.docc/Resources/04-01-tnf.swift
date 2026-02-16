import CoreNFC

// Type Name Format (TNF) 열거형
// 레코드의 타입 필드를 해석하는 방법을 정의

extension NFCTypeNameFormat: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "Empty (빈 레코드)"
        case .nfcWellKnown:
            return "Well-Known (NFC Forum 표준 타입)"
        case .media:
            return "Media (MIME 타입)"
        case .absoluteURI:
            return "Absolute URI"
        case .nfcExternal:
            return "External (커스텀 도메인)"
        case .unknown:
            return "Unknown (알 수 없음)"
        case .unchanged:
            return "Unchanged (청크 연속)"
        @unknown default:
            return "Unknown TNF"
        }
    }
}

func describeTNF(_ payload: NFCNDEFPayload) {
    print("TNF: \(payload.typeNameFormat)")
}
