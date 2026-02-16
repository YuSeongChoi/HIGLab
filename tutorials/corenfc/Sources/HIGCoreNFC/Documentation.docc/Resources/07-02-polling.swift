import CoreNFC

class TagReader: NSObject, NFCTagReaderSessionDelegate {
    var tagSession: NFCTagReaderSession?
    
    func startSession() {
        // 폴링 옵션 설정
        // 감지할 태그 타입을 지정
        let pollingOptions: NFCTagReaderSession.PollingOption = [
            .iso14443,   // ISO 7816, MIFARE
            .iso15693,   // NFC-V (vicinity cards)
            .iso18092    // FeliCa
        ]
        
        // 모든 타입을 폴링하거나, 필요한 것만 선택
        // 예: FeliCa만 읽으려면
        // let pollingOptions: NFCTagReaderSession.PollingOption = .iso18092
        
        tagSession = NFCTagReaderSession(
            pollingOption: pollingOptions,
            delegate: self
        )
        
        tagSession?.alertMessage = "태그를 iPhone에 가까이 대세요."
        tagSession?.begin()
    }
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) { }
    
    func tagReaderSession(_ session: NFCTagReaderSession, 
                          didDetect tags: [NFCTag]) { }
    
    func tagReaderSession(_ session: NFCTagReaderSession, 
                          didInvalidateWithError error: Error) {
        tagSession = nil
    }
}
