import CoreNFC

class FeliCaReader: NSObject, NFCTagReaderSessionDelegate {
    
    func inspectFeliCaTag(_ tag: NFCFeliCaTag) {
        // NFCFeliCaTag의 주요 속성
        
        // 1. currentIDm (Manufacture ID)
        // 8바이트 고유 식별자
        // - 처음 2바이트: 제조사 코드
        // - 나머지 6바이트: 카드 번호
        let idm = tag.currentIDm
        print("IDm: \(idm.hexString)")
        
        // 2. currentSystemCode
        // 현재 선택된 시스템 코드
        let systemCode = tag.currentSystemCode
        print("System Code: \(systemCode.hexString)")
        
        // 주요 시스템 코드
        // 0x88B4: 공통 영역 (일반 FeliCa)
        // 0x0003: Suica/PASMO
        // 0xFE00: NDEF
    }
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) { }
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) { }
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) { }
}

extension Data {
    var hexString: String {
        map { String(format: "%02X", $0) }.joined()
    }
}
