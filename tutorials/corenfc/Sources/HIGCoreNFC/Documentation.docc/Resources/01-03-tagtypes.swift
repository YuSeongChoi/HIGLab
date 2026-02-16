import CoreNFC
import UIKit

// CoreNFC가 지원하는 태그 타입
enum SupportedTagType: String, CaseIterable {
    /// NFC Data Exchange Format - 범용 데이터 포맷
    case ndef = "NDEF"
    
    /// 스마트카드 표준 (신용카드, 신분증)
    case iso7816 = "ISO 7816"
    
    /// 근거리 통신 표준 (NFC-V)
    case iso15693 = "ISO 15693"
    
    /// Sony의 비접촉 IC 기술 (Suica, PASMO)
    case feliCa = "FeliCa"
    
    /// NXP의 스마트카드 기술 (교통카드, 출입증)
    case mifare = "MIFARE"
}

class NFCReader: NSObject {
    var ndefSession: NFCNDEFReaderSession?
    
    var isNFCSupported: Bool {
        NFCNDEFReaderSession.readingAvailable
    }
    
    func printSupportedTags() {
        print("CoreNFC 지원 태그:")
        for tag in SupportedTagType.allCases {
            print("  - \(tag.rawValue)")
        }
    }
}
