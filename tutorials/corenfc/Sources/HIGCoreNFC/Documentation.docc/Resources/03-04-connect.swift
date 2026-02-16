import CoreNFC

class NFCReader: NSObject, NFCNDEFReaderSessionDelegate {
    var ndefSession: NFCNDEFReaderSession?
    
    func startScanning() {
        ndefSession = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: false  // 태그에 직접 연결하려면 false
        )
        ndefSession?.alertMessage = "NFC 태그를 스캔하세요"
        ndefSession?.begin()
    }
    
    // 태그 직접 접근 (iOS 13+)
    func readerSession(_ session: NFCNDEFReaderSession, 
                       didDetect tags: [NFCNDEFTag]) {
        guard let tag = tags.first else {
            session.invalidate(errorMessage: "태그를 찾을 수 없습니다.")
            return
        }
        
        // 태그에 연결
        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: "연결 실패: \(error.localizedDescription)")
                return
            }
            
            print("태그 연결 성공!")
            // 이제 태그를 읽거나 쓸 수 있음
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, 
                       didDetectNDEFs messages: [NFCNDEFMessage]) { }
    
    func readerSession(_ session: NFCNDEFReaderSession, 
                       didInvalidateWithError error: Error) { }
}
