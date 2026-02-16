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
        guard let tag = tags.first else {
            session.invalidate(errorMessage: "태그를 찾을 수 없습니다.")
            return
        }
        
        // 1. 태그에 연결
        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: "연결 실패: \(error.localizedDescription)")
                return
            }
            
            // 2. NDEF 상태 확인
            tag.queryNDEFStatus { status, capacity, error in
                if let error = error {
                    session.invalidate(errorMessage: error.localizedDescription)
                    return
                }
                
                switch status {
                case .notSupported:
                    session.invalidate(errorMessage: "NDEF를 지원하지 않습니다.")
                    
                case .readOnly:
                    session.invalidate(errorMessage: "읽기 전용 태그입니다.")
                    
                case .readWrite:
                    // 3. 용량 확인
                    guard let message = self.messageToWrite else { return }
                    let messageSize = message.length
                    
                    if messageSize > capacity {
                        session.invalidate(
                            errorMessage: "용량 부족: \(messageSize) > \(capacity) bytes"
                        )
                        return
                    }
                    
                    // 쓰기 가능!
                    self.writeToTag(tag, session: session)
                    
                @unknown default:
                    session.invalidate(errorMessage: "알 수 없는 상태")
                }
            }
        }
    }
    
    private func writeToTag(_ tag: NFCNDEFTag, session: NFCNDEFReaderSession) {
        // 다음 스텝에서 구현
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, 
                       didDetectNDEFs messages: [NFCNDEFMessage]) { }
    
    func readerSession(_ session: NFCNDEFReaderSession, 
                       didInvalidateWithError error: Error) {
        self.session = nil
    }
}
