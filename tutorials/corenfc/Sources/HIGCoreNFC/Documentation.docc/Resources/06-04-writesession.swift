import CoreNFC

class NFCWriter: NSObject, NFCNDEFReaderSessionDelegate {
    var session: NFCNDEFReaderSession?
    var messageToWrite: NFCNDEFMessage?
    var onComplete: ((Bool, String) -> Void)?
    
    func startWriteSession(message: NFCNDEFMessage) {
        guard NFCNDEFReaderSession.readingAvailable else {
            onComplete?(false, "NFC를 지원하지 않습니다.")
            return
        }
        
        messageToWrite = message
        
        // 쓰기를 위해 invalidateAfterFirstRead = false
        session = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: false  // 중요!
        )
        
        session?.alertMessage = "NFC 태그에 데이터를 쓰려면\n태그를 iPhone 상단에 대세요."
        session?.begin()
    }
    
    // MARK: - NFCNDEFReaderSessionDelegate
    
    func readerSession(_ session: NFCNDEFReaderSession, 
                       didDetect tags: [NFCNDEFTag]) {
        // 다음 스텝에서 구현
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, 
                       didDetectNDEFs messages: [NFCNDEFMessage]) { }
    
    func readerSession(_ session: NFCNDEFReaderSession, 
                       didInvalidateWithError error: Error) {
        self.session = nil
    }
}
