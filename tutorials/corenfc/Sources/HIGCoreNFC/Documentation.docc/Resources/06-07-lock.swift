import CoreNFC

class NFCWriter: NSObject, NFCNDEFReaderSessionDelegate {
    var session: NFCNDEFReaderSession?
    var messageToWrite: NFCNDEFMessage?
    var shouldLockAfterWrite: Bool = false
    var onComplete: ((Bool, String) -> Void)?
    
    func writeAndLock(message: NFCNDEFMessage) {
        // ⚠️ 경고: 잠금은 되돌릴 수 없습니다!
        shouldLockAfterWrite = true
        messageToWrite = message
        
        session = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: false
        )
        session?.alertMessage = "태그를 잠급니다. 이 작업은 되돌릴 수 없습니다!"
        session?.begin()
    }
    
    private func writeToTag(_ tag: NFCNDEFTag, session: NFCNDEFReaderSession) {
        guard let message = messageToWrite else { return }
        
        tag.writeNDEF(message) { error in
            if let error = error {
                session.invalidate(errorMessage: "쓰기 실패: \(error.localizedDescription)")
                return
            }
            
            if self.shouldLockAfterWrite {
                // 태그 잠금 (읽기 전용으로 만듦)
                tag.writeLock { error in
                    if let error = error {
                        session.invalidate(errorMessage: "잠금 실패: \(error.localizedDescription)")
                        self.onComplete?(false, "잠금 실패")
                        return
                    }
                    
                    session.alertMessage = "태그가 잠겼습니다! (읽기 전용)"
                    session.invalidate()
                    self.onComplete?(true, "쓰기 및 잠금 완료")
                }
            } else {
                session.alertMessage = "쓰기 완료!"
                session.invalidate()
                self.onComplete?(true, "쓰기 완료")
            }
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, 
                       didDetect tags: [NFCNDEFTag]) {
        guard let tag = tags.first else { return }
        
        session.connect(to: tag) { _ in
            tag.queryNDEFStatus { status, _, _ in
                guard status == .readWrite else {
                    session.invalidate(errorMessage: "쓸 수 없는 태그입니다.")
                    return
                }
                self.writeToTag(tag, session: session)
            }
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, 
                       didDetectNDEFs messages: [NFCNDEFMessage]) { }
    
    func readerSession(_ session: NFCNDEFReaderSession, 
                       didInvalidateWithError error: Error) {
        self.session = nil
    }
}
