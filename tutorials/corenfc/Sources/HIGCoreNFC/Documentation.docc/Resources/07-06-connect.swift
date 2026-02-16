import CoreNFC

class TagReader: NSObject, NFCTagReaderSessionDelegate {
    var tagSession: NFCTagReaderSession?
    
    func tagReaderSession(_ session: NFCTagReaderSession, 
                          didDetect tags: [NFCTag]) {
        guard let tag = tags.first else { return }
        
        // 태그에 연결
        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: "연결 실패: \(error.localizedDescription)")
                return
            }
            
            print("태그 연결 성공!")
            
            // 태그 타입에 따라 통신
            switch tag {
            case .iso7816(let iso7816Tag):
                self.communicateWithISO7816(iso7816Tag, session: session)
                
            case .feliCa(let feliCaTag):
                self.communicateWithFeliCa(feliCaTag, session: session)
                
            case .miFare(let miFareTag):
                self.communicateWithMIFARE(miFareTag, session: session)
                
            default:
                session.invalidate(errorMessage: "지원하지 않는 태그")
            }
        }
    }
    
    private func communicateWithISO7816(_ tag: NFCISO7816Tag, 
                                         session: NFCTagReaderSession) {
        // APDU 명령 전송 (챕터 8에서 자세히)
        print("ISO 7816 통신 시작")
    }
    
    private func communicateWithFeliCa(_ tag: NFCFeliCaTag, 
                                        session: NFCTagReaderSession) {
        // FeliCa 명령 전송 (챕터 9에서 자세히)
        print("FeliCa 통신 시작")
    }
    
    private func communicateWithMIFARE(_ tag: NFCMiFareTag, 
                                        session: NFCTagReaderSession) {
        // MIFARE 명령 전송 (챕터 9에서 자세히)
        print("MIFARE 통신 시작")
    }
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) { }
    
    func tagReaderSession(_ session: NFCTagReaderSession, 
                          didInvalidateWithError error: Error) {
        tagSession = nil
    }
}
