import CoreNFC

class TagReader: NSObject, NFCTagReaderSessionDelegate {
    var tagSession: NFCTagReaderSession?
    
    func tagReaderSession(_ session: NFCTagReaderSession, 
                          didDetect tags: [NFCTag]) {
        guard let tag = tags.first else { return }
        
        // NFCTag 열거형으로 타입 분기
        switch tag {
        case .iso7816(let tag):
            handleISO7816(tag, session: session)
            
        case .feliCa(let tag):
            handleFeliCa(tag, session: session)
            
        case .iso15693(let tag):
            handleISO15693(tag, session: session)
            
        case .miFare(let tag):
            handleMIFARE(tag, session: session)
            
        @unknown default:
            session.invalidate(errorMessage: "지원하지 않는 태그입니다.")
        }
    }
    
    private func handleISO7816(_ tag: NFCISO7816Tag, 
                                session: NFCTagReaderSession) {
        print("ISO 7816 처리")
        // 스마트카드 명령 전송
    }
    
    private func handleFeliCa(_ tag: NFCFeliCaTag, 
                               session: NFCTagReaderSession) {
        print("FeliCa 처리")
        // FeliCa 명령 전송
    }
    
    private func handleISO15693(_ tag: NFCISO15693Tag, 
                                 session: NFCTagReaderSession) {
        print("ISO 15693 처리")
        // NFC-V 명령 전송
    }
    
    private func handleMIFARE(_ tag: NFCMiFareTag, 
                               session: NFCTagReaderSession) {
        print("MIFARE 처리")
        // MIFARE 명령 전송
    }
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) { }
    
    func tagReaderSession(_ session: NFCTagReaderSession, 
                          didInvalidateWithError error: Error) {
        tagSession = nil
    }
}
