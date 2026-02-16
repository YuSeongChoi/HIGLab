import CoreNFC

class TagReader: NSObject, NFCTagReaderSessionDelegate {
    var tagSession: NFCTagReaderSession?
    
    // MARK: - NFCTagReaderSessionDelegate
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        // 세션 활성화됨
        print("태그 리더 세션 활성화")
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, 
                          didDetect tags: [NFCTag]) {
        // 태그 감지됨
        print("태그 감지: \(tags.count)개")
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, 
                          didInvalidateWithError error: Error) {
        // 세션 종료 또는 에러
        if let nfcError = error as? NFCReaderError {
            switch nfcError.code {
            case .readerSessionInvalidationErrorUserCanceled:
                print("사용자가 취소함")
            case .readerSessionInvalidationErrorSessionTimeout:
                print("세션 시간 초과")
            default:
                print("에러: \(nfcError.localizedDescription)")
            }
        }
        tagSession = nil
    }
}
