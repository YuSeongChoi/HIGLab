import CoreNFC
import UIKit

// CoreNFC 요구사항
// - iPhone 7 이상
// - iOS 11+ (NDEF 읽기)
// - iOS 13+ (태그 쓰기, 백그라운드 읽기)

class NFCReader: NSObject {
    // NFC 세션 인스턴스
    var ndefSession: NFCNDEFReaderSession?
    
    // 디바이스 NFC 지원 여부 확인
    var isNFCSupported: Bool {
        NFCNDEFReaderSession.readingAvailable
    }
}
