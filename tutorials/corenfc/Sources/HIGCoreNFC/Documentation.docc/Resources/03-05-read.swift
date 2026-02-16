import CoreNFC

class NFCReader: NSObject, NFCNDEFReaderSessionDelegate {
    var ndefSession: NFCNDEFReaderSession?
    var onMessageRead: ((NFCNDEFMessage) -> Void)?
    
    func readerSession(_ session: NFCNDEFReaderSession, 
                       didDetect tags: [NFCNDEFTag]) {
        guard let tag = tags.first else { return }
        
        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: error.localizedDescription)
                return
            }
            
            // 1. NDEF 상태 확인
            tag.queryNDEFStatus { status, capacity, error in
                if let error = error {
                    session.invalidate(errorMessage: error.localizedDescription)
                    return
                }
                
                switch status {
                case .notSupported:
                    session.invalidate(errorMessage: "NDEF를 지원하지 않는 태그입니다.")
                    
                case .readOnly:
                    print("읽기 전용 태그 (용량: \(capacity) bytes)")
                    self.readTag(tag, session: session)
                    
                case .readWrite:
                    print("읽기/쓰기 가능 (용량: \(capacity) bytes)")
                    self.readTag(tag, session: session)
                    
                @unknown default:
                    session.invalidate(errorMessage: "알 수 없는 상태")
                }
            }
        }
    }
    
    private func readTag(_ tag: NFCNDEFTag, session: NFCNDEFReaderSession) {
        // 2. NDEF 메시지 읽기
        tag.readNDEF { message, error in
            if let error = error {
                session.invalidate(errorMessage: "읽기 실패: \(error.localizedDescription)")
                return
            }
            
            if let message = message {
                session.alertMessage = "태그 읽기 완료!"
                session.invalidate()
                self.onMessageRead?(message)
            }
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, 
                       didDetectNDEFs messages: [NFCNDEFMessage]) { }
    
    func readerSession(_ session: NFCNDEFReaderSession, 
                       didInvalidateWithError error: Error) { }
}
