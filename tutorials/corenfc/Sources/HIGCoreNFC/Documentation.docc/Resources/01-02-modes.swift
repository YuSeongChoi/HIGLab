import CoreNFC
import UIKit

// NFC의 세 가지 동작 모드
enum NFCMode {
    /// Reader/Writer 모드: 태그를 읽고 씁니다
    /// - CoreNFC가 지원하는 모드
    case readerWriter
    
    /// Peer-to-Peer 모드: 두 기기 간 데이터 교환
    /// - iOS에서는 지원하지 않음
    case peerToPeer
    
    /// Card Emulation 모드: 기기가 카드처럼 동작
    /// - Apple Pay에서 사용
    /// - 서드파티 앱에서는 직접 접근 불가
    case cardEmulation
}

class NFCReader: NSObject {
    var ndefSession: NFCNDEFReaderSession?
    
    var isNFCSupported: Bool {
        NFCNDEFReaderSession.readingAvailable
    }
}
