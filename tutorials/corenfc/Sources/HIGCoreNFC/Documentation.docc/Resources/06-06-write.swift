import CoreNFC

class NFCWriter: NSObject, NFCNDEFReaderSessionDelegate {
    var session: NFCNDEFReaderSession?
    var messageToWrite: NFCNDEFMessage?
    var onComplete: ((Bool, String) -> Void)?
    
    func startWriteSession(message: NFCNDEFMessage) {
        messageToWrite = message
        session = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: false
        )
        session?.alertMessage = "태그를 iPhone에 대세요."
        session?.begin()
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, 
                       didDetect tags: [NFCNDEFTag]) {
        guard let tag = tags.first else { return }
        
        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: error.localizedDescription)
                return
            }
            
            tag.queryNDEFStatus { status, capacity, _ in
                guard status == .readWrite,
                      let message = self.messageToWrite,
                      message.length <= capacity else {
                    session.invalidate(errorMessage: "쓸 수 없는 태그입니다.")
                    return
                }
                
                self.writeToTag(tag, session: session)
            }
        }
    }
    
    private func writeToTag(_ tag: NFCNDEFTag, session: NFCNDEFReaderSession) {
        guard let message = messageToWrite else { return }
        
        // NDEF 메시지 쓰기
        tag.writeNDEF(message) { error in
            if let error = error {
                session.invalidate(errorMessage: "쓰기 실패: \(error.localizedDescription)")
                self.onComplete?(false, error.localizedDescription)
                return
            }
            
            // 성공!
            session.alertMessage = "태그에 데이터를 썼습니다!"
            session.invalidate()
            self.onComplete?(true, "성공")
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, 
                       didDetectNDEFs messages: [NFCNDEFMessage]) { }
    
    func readerSession(_ session: NFCNDEFReaderSession, 
                       didInvalidateWithError error: Error) {
        self.session = nil
    }
}

// 사용 예시
func writeURLToTag() {
    let writer = NFCWriter()
    
    guard let url = URL(string: "https://apple.com"),
          let payload = NFCNDEFPayload.wellKnownTypeURIPayload(url: url) else {
        return
    }
    
    let message = NFCNDEFMessage(records: [payload])
    
    writer.onComplete = { success, message in
        print(success ? "쓰기 성공!" : "쓰기 실패: \(message)")
    }
    
    writer.startWriteSession(message: message)
}
