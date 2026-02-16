import CoreNFC

class TagReader: NSObject, NFCTagReaderSessionDelegate {
    var tagSession: NFCTagReaderSession?
    
    var isAvailable: Bool {
        NFCTagReaderSession.readingAvailable
    }
    
    func startSession() {
        // 지원 여부 확인
        guard isAvailable else {
            print("NFC 태그 읽기를 지원하지 않습니다.")
            return
        }
        
        let pollingOptions: NFCTagReaderSession.PollingOption = [
            .iso14443, .iso15693, .iso18092
        ]
        
        tagSession = NFCTagReaderSession(
            pollingOption: pollingOptions,
            delegate: self
        )
        
        tagSession?.alertMessage = "태그를 iPhone에 가까이 대세요."
        
        // 세션 시작
        tagSession?.begin()
        print("NFC 태그 스캔 시작...")
    }
    
    func stopSession() {
        tagSession?.invalidate()
        tagSession = nil
    }
    
    func restartPolling() {
        // 태그 처리 후 다시 폴링 시작
        tagSession?.restartPolling()
    }
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("스캔 준비 완료")
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, 
                          didDetect tags: [NFCTag]) {
        print("태그 감지됨!")
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, 
                          didInvalidateWithError error: Error) {
        tagSession = nil
    }
}
